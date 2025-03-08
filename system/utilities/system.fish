#!/usr/bin/env fish

set option (echo 'img:/usr/share/icons/Arc/panel/22/nm-vpn-standalone-lock.svg:text:Lock
img:/usr/share/icons/Arc/panel/22/avatar-default.svg:text:Logout
img:/usr/share/icons/Arc/panel/22/user-status-pending.svg:text:Sleep
img:/usr/share/icons/Arc/panel/22/network-error.svg:text:Hibernate
img:/usr/share/icons/Arc/panel/22/network-transmit-receive.svg:text:Reboot
img:/usr/share/icons/Arc/panel/22/system-devices-panel.svg:text:Poweroff' \
    | wofi --dmenu --prompt '' --cache-file /dev/null \
    | cut -d ':' -f 4)

switch $option
    case Lock
        swaylock --image (wallpaper --current)
    case Logout
        swaymsg exit
    case Sleep
        systemctl suspend
    case Hibernate
        if findmnt --output TARGET --noheadings --raw | grep --quiet '^/media'
            notify-send --app-name system --icon dialog-warning --urgency critical \
                "CANNOT HIBERNATE" \
                "There is media mounted at \n$(findmnt --output TARGET --noheadings --raw | grep '^/media')"
            pw-play /usr/share/sounds/freedesktop/stereo/dialog-warning.oga
            exit 1
        end
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 50%
        systemctl hibernate
    case Reboot
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 50%
        systemctl reboot
    case Poweroff
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 50%
        systemctl poweroff
    case '*'
        exit 1
end
