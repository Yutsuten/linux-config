#!/bin/bash
# --------------------------------- #
# Take screenshot using ImageMagick #
# --------------------------------- #

set -e
set -u

SCREENSHOT_DIR="${HOME}/Pictures/Screenshots"
IMG_NAME="Screenshot_$(date '+%Y%m%d_%H%M%S%N' | cut -b -17).png"

case $1 in
  --full)
    import -window root "${SCREENSHOT_DIR}/${IMG_NAME}"
    notify-send -a Screenshot -i "${SCREENSHOT_DIR}/${IMG_NAME}" 'Full screen capture' "File saved to ${SCREENSHOT_DIR}"
    ;;
  --active)
    WIN_ID="$(xprop -root _NET_ACTIVE_WINDOW | cut -d ' ' -f 5)"
    import -screen -frame -window "${WIN_ID}" "${SCREENSHOT_DIR}/${IMG_NAME}"
    notify-send -a Screenshot -i "${SCREENSHOT_DIR}/${IMG_NAME}" 'Active window capture' "File saved to ${SCREENSHOT_DIR}"
    ;;
  --select)
    import "${SCREENSHOT_DIR}/${IMG_NAME}"
    notify-send -a Screenshot -i "${SCREENSHOT_DIR}/${IMG_NAME}" 'Selected area capture' "File saved to ${SCREENSHOT_DIR}"
    ;;
  *)
    printf "Invalid option.\n" >&2
    exit 1
    ;;
esac
