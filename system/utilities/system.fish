#!/usr/bin/env fish

set option (echo 'img:/usr/share/icons/Arc/panel/22/nm-vpn-standalone-lock.svg:text:Lock
img:/usr/share/icons/Arc/panel/22/avatar-default.svg:text:Logout
img:/usr/share/icons/Arc/panel/22/user-status-pending.svg:text:Sleep
img:/usr/share/icons/Arc/panel/22/network-error.svg:text:Hibernate
img:/usr/share/icons/Arc/panel/22/network-transmit-receive.svg:text:Reboot
img:/usr/share/icons/Arc/panel/22/system-devices-panel.svg:text:Poweroff' \
    | wofi --show dmenu --prompt '' --cache-file /dev/null \
    | cut -d ':' -f 4)

switch $option
    case Lock
        swaylock --image (wallpaper --current)
    case Logout
        if pgrep --exact ffmpeg &>/dev/null
            notify-send --app-name system --icon dialog-warning --urgency critical 'LOGOUT ABORTED' 'A ffmpeg process is currently running.'
            pw-play /usr/share/sounds/freedesktop/stereo/dialog-warning.oga
            exit 1
        end
        swaymsg exit
    case Sleep
        systemctl suspend
    case Hibernate
        set mounted_media (findmnt --output TARGET --noheadings --raw | string match '/media*')
        if test -n "$mounted_media"
            notify-send --app-name system --icon dialog-warning --urgency critical 'HIBERNATE ABORTED' "There is media mounted at\n$mounted_media"
            pw-play /usr/share/sounds/freedesktop/stereo/dialog-warning.oga
            exit 1
        end
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 50%
        systemctl hibernate
    case Reboot
        if pgrep --exact ffmpeg &>/dev/null
            notify-send --app-name system --icon dialog-warning --urgency critical 'REBOOT ABORTED' 'A ffmpeg process is currently running.'
            pw-play /usr/share/sounds/freedesktop/stereo/dialog-warning.oga
            exit 1
        end
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 50%
        systemctl reboot
    case Poweroff
        if pgrep --exact ffmpeg &>/dev/null
            notify-send --app-name system --icon dialog-warning --urgency critical 'POWEROFF ABORTED' 'A ffmpeg process is currently running.'
            pw-play /usr/share/sounds/freedesktop/stereo/dialog-warning.oga
            exit 1
        end
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 50%
        systemctl poweroff
    case '*'
        exit 1
end
