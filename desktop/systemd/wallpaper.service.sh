#!/usr/bin/bash

set -e
set -u

cat > ~/.config/systemd/user/wallpaper.service << WALLPAPER_SERVICE
[Unit]
Description=set random wallpaper

[Service]
Type=oneshot
EnvironmentFile=${HOME}/.local/environment
ExecStart=/usr/local/bin/wallpaper --random

[Install]
WantedBy=multi-user.target
WALLPAPER_SERVICE
