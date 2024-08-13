#!/usr/bin/env fish

if pgrep --full 'fish /usr/local/bin/record'
    # Stop recording
    pkill --signal SIGINT --full 'fish /usr/local/bin/record' &
    notify-send --urgency low --app-name Record --icon process-completed-symbolic 'Finished recording screen' &
    pw-play /usr/share/sounds/freedesktop/stereo/service-logout.oga &
else
    # Start recording
    mkdir --parents ~/.local/logs
    record &> ~/.local/logs/record.log &
    notify-send --urgency low --app-name Record --icon software-update-urgent-symbolic 'Recording screen' &
    pw-play /usr/share/sounds/freedesktop/stereo/service-login.oga &
end
