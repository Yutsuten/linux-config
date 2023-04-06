#!/bin/bash

option=$(echo ' Lock
 Logout
 Sleep
 Hibernate
 Reboot
 Poweroff' | wofi --dmenu --prompt '' --cache-file /dev/null)

case ${option} in
  ' Lock')
    swaylock
    ;;
  ' Logout')
    swaymsg exit
    ;;
  ' Sleep')
    systemctl suspend
    ;;
  ' Hibernate')
    systemctl hibernate
    ;;
  ' Reboot')
    systemctl reboot
    ;;
  ' Poweroff')
    systemctl poweroff
    ;;
  *)
    exit 1
    ;;
esac
