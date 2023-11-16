#!/bin/bash

set -o pipefail

option=$(echo 'img:/usr/share/icons/Arc/panel/22/nm-vpn-standalone-lock.svg:text:Lock
img:/usr/share/icons/Arc/panel/22/avatar-default.svg:text:Logout
img:/usr/share/icons/Arc/panel/22/user-status-pending.svg:text:Sleep
img:/usr/share/icons/Arc/panel/22/network-error.svg:text:Hibernate
img:/usr/share/icons/Arc/panel/22/network-transmit-receive.svg:text:Reboot
img:/usr/share/icons/Arc/panel/22/system-devices-panel.svg:text:Poweroff' \
  | wofi --dmenu --prompt '' --cache-file /dev/null \
  | cut -d ':' -f 4)

want_to() {
  if findmnt --output TARGET --noheadings --raw | grep --quiet '^/media'; then
    notify-send --app-name system --icon dialog-warning --urgency critical \
      "CANNOT $1" \
      "There is media mounted at \n$(findmnt --output TARGET --noheadings --raw | grep '^/media')"
    exit 1
  fi
}

case ${option} in
  'Lock')
    swaylock --image ~/Pictures/Wallpapers/"$(head -n 1 ~/.cache/wallpaper)"
    ;;
  'Logout')
    swaymsg exit
    ;;
  'Sleep')
    want_to SLEEP
    systemctl suspend
    ;;
  'Hibernate')
    want_to HIBERNATE
    wpctl set-volume @DEFAULT_AUDIO_SINK@ 50%
    systemctl hibernate
    ;;
  'Reboot')
    wpctl set-volume @DEFAULT_AUDIO_SINK@ 50%
    systemctl reboot
    ;;
  'Poweroff')
    wpctl set-volume @DEFAULT_AUDIO_SINK@ 50%
    systemctl poweroff
    ;;
  *)
    exit 1
    ;;
esac
