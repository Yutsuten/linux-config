#!/usr/bin/env fish

if pgrep --full 'fish /usr/local/bin/record'
    # Stop recording
    pkill --signal INT --full 'fish /usr/local/bin/record'
    notify-send --urgency low --app-name record --icon process-completed-symbolic 'Finished recording screen' &
    pw-play /usr/share/sounds/freedesktop/stereo/service-logout.oga &
    pkill --signal CONT ffmpeg # Continue video reencoding if we stopped any
else
    # Start recording
    record-settings
    pkill --signal STOP ffmpeg # Stop any video reencoding if any
    mkdir --parents ~/.local/logs
    record --waybar &>~/.local/logs/record.log &
    notify-send --urgency low --app-name record --icon software-update-urgent-symbolic 'Recording screen' &
    pw-play /usr/share/sounds/freedesktop/stereo/service-login.oga &
end

return 0
