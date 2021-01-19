#!/bin/bash
# ---------------------------- #
# Generate configuration files #
# ---------------------------- #

set -e

cat > /usr/share/applications/osu.desktop << EOF
[Desktop Entry]
Type=Application
Name=osu
Comment=Rhythm is just a click away
Categories=Game
Exec=/home/mateus/Packages/AppImages/osu.AppImage
Icon=/home/mateus/Pictures/Icons/osu-lazer.png
Terminal=0
EOF

cat > /etc/X11/xorg.conf.d/72-wacom-options.conf << EOF
Section "InputClass"
	Identifier "WACOM Pen stylus"
	MatchDriver "wacom"
	MatchProduct "Pen"
	NoMatchProduct "eraser"
	Option "Type" "stylus"
	Option "TopX" "2280"
	Option "TopY" "1425"
	Option "BottomX" "12920"
	Option "BottomY" "8075"
	Option "Button1" "0"
EndSection
EOF

cat > /etc/lightdm/slick-greeter.conf << EOF
[Greeter]
background=/usr/share/pixmaps/lightdm_bg.png
show-a11y=false
clock-format=%Y年%m月%d日 (%a) %H:%M:%S
EOF
