#!/usr/bin/bash

# uosc
wget -qP /tmp 'https://github.com/tomasklaen/uosc/releases/latest/download/uosc.zip'
unar -quiet -force-overwrite -no-directory -output-directory ~/.config/mpv/ /tmp/uosc.zip
rm -f /tmp/uosc.zip

# thumbfast
wget -qNP ~/.config/mpv/scripts 'https://raw.githubusercontent.com/po5/thumbfast/master/thumbfast.lua'
