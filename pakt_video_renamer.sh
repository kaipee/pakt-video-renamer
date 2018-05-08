#!/bin/bash

# Author:	Keith Patton 2018
# Brief:	A BASH script to obtain video file names from a
# 		DOCX file that is supplied with videos from PAKT

####################
## Script options ##
####################
DEBUG="false" # Enable/disable debug options
OUTPUT="quick" # Pretty output : quick,slow,disabled

######################
## Script variables ##
######################
INPUT="$1"
DIR=$(dirname "$1")
FILE=$(basename "$1")
FILENAME=${1%.*}
TXTFILE="$FILENAME.txt"
LOG="headings.log"
SANITIZED="clean.log"

######################
## Script functions ##
######################
## Display files and paths for easy debugging
function debug {
  printf "\n"
  echo "WORKING ON FILE : $INPUT"
  echo "THE PATH IS : $DIR"
  echo "THE FILE IS : $FILE"
  echo "THE FILENAME IS : $FILENAME"
  echo "THE TEXTFILE IS : $TXTFILE"
  printf "\n"
  sleep 1 # pretty output
}

## Output speed
function output_speed {
  if [ "$OUTPUT" = "slow" ]; then
    sleep 2
  else
    :
  fi
}

## Wait for confirmation to proceed
function continue_on {
  while true; do
    read -r -p "Continue? (y/n) " dir_confirm
    case $dir_confirm in
      [Yy]* )
        break;;
      [Nn]* )
        echo "EXITING..."
        exit 1;;
      * ) printf "Please answer y or n.";;
    esac
  done
}

function cleanup {
  declare -a FILES=("$LOG" "$SANITIZED")
  for item in ${FILES[*]}
  do
    if [ -f "$item" ]; then
      rm "$item"
    fi
  done

  if [ -f "$TXTFILE" ]; then # TODO - TEXTFILE likely contains spaces, need to expand into array value within single quotes
    rm "$TXTFILE"
  fi
}
###############
# The script ##
###############
## Debug if enabled
if [ $DEBUG = "true" ]; then
  debug
fi

## Clear up files from any previous attempts
cleanup

## Convert from DOCX to plain text
output_speed
printf '\n%s\n' "## Converting DOCX to PLAIN TEXT..."
output_speed
# TODO : check file being passed for conversion is actually a DOCX file
docx2txt "$1" "$TXTFILE"
if [ -f "$TXTFILE" ]; then
  printf '%s\n' "## DONE"
  if [ "$OUTPUT" = "slow" ] || [ "$OUTPUT" = "quick" ]; then
    printf "\n"
    continue_on
  fi
else
  printf '%s\n' "## SOMETHING WENT WRONG!! ABORTING..."
  exit
fi

## grep textfile for any Headings in chapter format starting like "1.1" (0-100 for up to 100 videos per chapter) and save to a log
printf '\n%s\n\n' "## Finding filenames from document headings"
grep -E "^(100|[1-9]|[1-9][0-9]).(100|[1-9]|[1-9][0-9])" "$TXTFILE" > "$LOG"

## Display a pretty output to notify of parsed filenames
case "$OUTPUT" in
"quick")
  cat "$LOG"
  printf '%s\n\n' "## DONE"
  continue_on
  ;;
"slow")
  sleep 2
  awk '{print $0; system("sleep .3");}' "$LOG"
  printf '%s\n\n' "## DONE"
  continue_on
  ;;
*)
  printf '%s\n\n' "## DONE"
  true
  ;;
esac

## Sanitize the headings
printf '\n%s\n\n' "## Sanitizing the headings for filenames..."
while read line;
do
  CLEAN=${line//  / } # Replace two spaces with space
  CLEAN=${line//   / } # Replace three spaces with space
  CLEAN=${line//    / } # Replace four spaces with space
  CLEAN=${CLEAN// 	/ } # Replace space+tab with space
  CLEAN=${CLEAN//  	/ } # Replace 2 space+tab with space
  CLEAN=${CLEAN//	/ } # Replace tab with space
  CLEAN=${CLEAN//		/ } # Replace double tab with space
  CLEAN=${CLEAN//[^a-zA-Z0-9 -,._()]/}
  echo $CLEAN >> "$SANITIZED"
done < "$LOG"

## Display a pretty output to notify of sanitized filenames
case "$OUTPUT" in
"quick")
  cat "$SANITIZED"
  printf '%s\n\n' "## DONE"
  continue_on
  ;;
"slow")
  output_speed
  awk '{print $0; system("sleep .3");}' "$SANITIZED"
  printf '%s\n\n' "## DONE"
  continue_on
  ;;
*)
  printf '%s\n\n' "## DONE"
  true
  ;;
esac

## Save MP4 files to array
i=0
declare -a VIDEOS
for filename in *.mp4; do
  filename=${filename%.*}
  VIDEOS[$i]="$filename"        
  (( i++ ))
done

## Output the array to verify
output_speed
printf '\n%s\n\n' "## Gathering video filenames..."
#printf '%s\n' "${VIDEOS[@]}"
for VIDEO in "${VIDEOS[@]}"; do
  printf '%s\n' "video found : $VIDEO"
done
printf '%s\n\n' "## DONE"
continue_on

## Sort video filenames with natural sort
output_speed
printf '\n%s\n\n' "## Sorting video filenames"
declare -a SORTED
SORTED=( $(printf '%s\n' "${VIDEOS[@]}" | sort -V) )
printf '%s\n' "${SORTED[@]}"
printf '%s\n\n' "## DONE"

## Compare number of video files with number of titles

## Rename video files with headings from array
# TODO : give output of renaming process
# TODO : create better working directory
# TODO : better handle actual video file types (do not assume all mp4)
mkdir ./renamed
fn=0
while read name; do
  cp "${SORTED[$fn]}.mp4" "./renamed/$name.mp4"
  (( fn++ ))
done < "$SANITIZED"

## Cleanup after ourself
# TODO : cleanup working directories
cleanup
