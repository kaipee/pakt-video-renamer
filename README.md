# Pakt Video Renamer

PVR is a quick and dirty BASH script to rename video files provided by Pakt Publishing.

## How it works

Pakt Publishing provides video tutorials for various subjects, for which they allow downloading. However, the video files are never named correclty (relating to the chapter / video subject), instead being named incrementally such as:
* **VIDEO_1.1.mp4**
* **VIDEO_1.2.mp4**
* **VIDEO_2.1.mp4**

Alongside the video files is an accompanying DOCX Word document which details the contents of each video file, along with a chapter / video title.

This script parses through the DOCX file and renames the video files according to the chapter titles expressed in the document.

## Usage

Simply execute the script from within the extracted archive downloaded from Pakt.

```sh
$ pakt_viedo_renamer.sh ./*.docx
```
