#!/bin/sh
# Called by sxiv(1) whenever an image gets loaded.
# The output is displayed in sxiv's status bar.
# Arguments:
#   $1: path to image file
#   $2: image width
#   $3: image height

filename=$(basename -- "$1")
filesize=$(du -Hh -- "$1" | cut -f 1)
geometry="${2}x${3}"

echo "${filename} | ${geometry} | ${filesize}"