#!/usr/bin/env fish
# -------------------------------------------------- #
# Take screenshots from a Wayland compositor.        #
#                                                    #
# SCREENSHOTS_PATH environment variable is required. #
# -------------------------------------------------- #

if not test -d "$SCREENSHOTS_PATH"
    echo 'SCREENSHOTS_PATH environment variable not set' >&2
    return 1
end

set NOTIFY notify-send --app-name Screenshot --action open
set PLAY pw-play /usr/share/sounds/freedesktop/stereo/screen-capture.oga

set output (date '+%Y-%m-%d-%H-%M-%S_%N')

switch $argv[1]
    case --full
        set output $output-full.png
        grim $SCREENSHOTS_PATH/$output
        $PLAY &
        $NOTIFY --icon $SCREENSHOTS_PATH/$output 'Full screen capture' "$output\n" | xargs test 0 -eq &>/dev/null && mvi $SCREENSHOTS_PATH/$output
    case --active
        set output $output-active.png
        set FOCUSED (swaymsg -t get_tree | jq -r 'recurse(.nodes[]?, .floating_nodes[]?) | select(.focused)')
        set GEOM (echo "$FOCUSED" | jq -r '.rect | "\(.x),\(.y) \(.width)x\(.height)"')
        grim -g $GEOM $SCREENSHOTS_PATH/$output
        $PLAY &
        $NOTIFY --icon $SCREENSHOTS_PATH/$output 'Active window capture' "$output\n" | xargs test 0 -eq 2>/dev/null && mvi $SCREENSHOTS_PATH/$output
    case --select
        set output $output-select.png
        set GEOM (slurp)
        if test -z "$GEOM"
            then
            exit 1
        end
        grim -g $GEOM $SCREENSHOTS_PATH/$output
        $PLAY &
        $NOTIFY --icon $SCREENSHOTS_PATH/$output 'Selected area capture' "$output\n" | xargs test 0 -eq 2>/dev/null && mvi $SCREENSHOTS_PATH/$output
    case '*'
        echo 'Invalid option.' >&2
        echo 'Valid options: --full --active --select' >&2
        return 1
end

return 0
