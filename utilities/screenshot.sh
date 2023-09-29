#!/bin/bash
# ------------------------ #
# Take screenshot in sway. #
# ------------------------ #

set -e
set -u

SCREENSHOT_DIR="${HOME}/Pictures/Screenshots"
IMG_NAME="$(date '+%Y-%m-%d-%H-%M-%S_%N')"

NOTIFY="notify-send --urgency low --app-name Screenshot"

case $1 in
  --full)
    IMG_NAME="${IMG_NAME}-full.png"
    grim "${SCREENSHOT_DIR}/${IMG_NAME}"
    ${NOTIFY} --icon "${SCREENSHOT_DIR}/${IMG_NAME}" 'Full screen capture' "${IMG_NAME}"
    ;;
  --active)
    IMG_NAME="${IMG_NAME}-active.png"
    FOCUSED=$(swaymsg -t get_tree | jq -r 'recurse(.nodes[]?, .floating_nodes[]?) | select(.focused)')
    GEOM=$(echo "$FOCUSED" | jq -r '.rect | "\(.x),\(.y) \(.width)x\(.height)"')
    grim -g "${GEOM}" "${SCREENSHOT_DIR}/${IMG_NAME}"
    ${NOTIFY} --icon "${SCREENSHOT_DIR}/${IMG_NAME}" 'Active window capture' "${IMG_NAME}"
    ;;
  --select)
    IMG_NAME="${IMG_NAME}-select.png"
    GEOM=$(slurp)
    if [[ -z "${GEOM}" ]]; then
      exit 1
    fi
    grim -g "${GEOM}" "${SCREENSHOT_DIR}/${IMG_NAME}"
    ${NOTIFY} --icon "${SCREENSHOT_DIR}/${IMG_NAME}" 'Selected area capture' "${IMG_NAME}"
    ;;
  *)
    printf "Invalid option.\n" >&2
    exit 1
    ;;
esac

pw-play /usr/share/sounds/freedesktop/stereo/screen-capture.oga
