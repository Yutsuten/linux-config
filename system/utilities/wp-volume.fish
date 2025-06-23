#!/usr/bin/env fish
argparse h/help -- $argv
set exitcode $status

function show_help
    echo 'Usage: wp-volume [toggle-mute|VOL[%][-/+]]' >&2
    echo >&2
    echo '  Synopsis:' >&2
    echo '    Change volume or toggle mute state.' >&2
    echo >&2
    echo '  Options:' >&2
    echo '    -h, --help      Show list of command-line options' >&2
    echo >&2
    echo '  Positional arguments:' >&2
    echo '    toggle-mute     Toggle mute state'
    echo '    VOL[%][-/+]     Increase or decrease current volume'
end

if test (count $argv) -ne 1 || set --query --local _flag_help
    show_help
    return 1
end

if test $argv[1] = toggle-mute
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
else
    if not wpctl set-volume @DEFAULT_AUDIO_SINK@ $argv[1] &>/dev/null
        show_help
        return 1
    end
end

pw-play /usr/share/sounds/freedesktop/stereo/audio-volume-change.oga &
set play_pid $last_pid

set state (wpctl get-volume @DEFAULT_AUDIO_SINK@)

if string match --quiet --entire MUTED $state
    notify-send --replace-id 9999 --app-name wp-volume --icon audio-volume-muted-symbolic --urgency low 'Volume: Muted'
else
    set volume (math "$(echo $state | cut -d ' ' -f 2) * 100")
    if test $volume -le 33
        set icon audio-volume-low-symbolic
    else if test $volume -le 66
        set icon audio-volume-medium-symbolic
    else
        set icon audio-volume-high-symbolic
    end
    notify-send --replace-id 9999 --app-name wp-volume --icon $icon --urgency low -h "int:value:$volume" "Volume: $volume%" &
    set notify_pid $last_pid
end

wait $notify_pid $play_pid
