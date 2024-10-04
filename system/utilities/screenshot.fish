#!/usr/bin/env fish
# ------------------------ #
# Take screenshot in sway. #
# ------------------------ #

set SCREENSHOT_DIR ~/Pictures/Screenshots
set IMG_NAME (date '+%Y-%m-%d-%H-%M-%S_%N')

set NOTIFY notify-send --app-name Screenshot --action=open
set PLAY pw-play /usr/share/sounds/freedesktop/stereo/screen-capture.oga

switch $argv[1]
    case --full
        set IMG_NAME $IMG_NAME-full.png
        grim $SCREENSHOT_DIR/$IMG_NAME
        $PLAY &
        $NOTIFY --icon $SCREENSHOT_DIR/$IMG_NAME 'Full screen capture' "$IMG_NAME\n(Middle click to open)" | xargs test 0 -eq &>/dev/null && mvi $SCREENSHOT_DIR/$IMG_NAME
    case --active
        set IMG_NAME $IMG_NAME-active.png
        set FOCUSED (swaymsg -t get_tree | jq -r 'recurse(.nodes[]?, .floating_nodes[]?) | select(.focused)')
        set GEOM (echo "$FOCUSED" | jq -r '.rect | "\(.x),\(.y) \(.width)x\(.height)"')
        grim -g $GEOM $SCREENSHOT_DIR/$IMG_NAME
        $PLAY &
        $NOTIFY --icon $SCREENSHOT_DIR/$IMG_NAME 'Active window capture' "$IMG_NAME\n(Middle click to open)" | xargs test 0 -eq 2>/dev/null && mvi $SCREENSHOT_DIR/$IMG_NAME
    case --select
        set IMG_NAME $IMG_NAME-select.png
        set GEOM (slurp)
        if test -z "$GEOM"
            then
            exit 1
        end
        grim -g $GEOM $SCREENSHOT_DIR/$IMG_NAME
        $PLAY &
        $NOTIFY --icon $SCREENSHOT_DIR/$IMG_NAME 'Selected area capture' "$IMG_NAME\n(Middle click to open)" | xargs test 0 -eq 2>/dev/null && mvi $SCREENSHOT_DIR/$IMG_NAME
    case '*'
        echo 'Invalid option.' >&2
        echo 'Valid options: --full --active --select' >&2
        return 1
end

return 0
