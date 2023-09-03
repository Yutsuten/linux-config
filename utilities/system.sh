#!/bin/bash

option=$(echo 'img:/usr/share/icons/Arc/panel/22/nm-vpn-standalone-lock.svg:text:Lock
img:/usr/share/icons/Arc/panel/22/avatar-default.svg:text:Logout
img:/usr/share/icons/Arc/panel/22/user-status-pending.svg:text:Sleep
img:/usr/share/icons/Arc/panel/22/network-error.svg:text:Hibernate
img:/usr/share/icons/Arc/panel/22/network-transmit-receive.svg:text:Reboot
img:/usr/share/icons/Arc/panel/22/system-devices-panel.svg:text:Poweroff' \
  | wofi --dmenu --prompt '' --cache-file /dev/null \
  | cut -d ':' -f 4)

case ${option} in
  'Lock')
    swaylock
    ;;
  'Logout')
    swaymsg exit
    ;;
  'Sleep')
    systemctl suspend
    ;;
  'Hibernate')
    wpctl set-volume @DEFAULT_AUDIO_SINK@ 50%
    systemctl hibernate
    ;;
  'Reboot')
    systemctl reboot
    ;;
  'Poweroff')
    systemctl poweroff
    ;;
  *)
    exit 1
    ;;
esac
