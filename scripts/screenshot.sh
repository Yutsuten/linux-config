#!/bin/bash
# --------------------------------- #
# Take screenshot using ImageMagick #
# --------------------------------- #

set -e
set -u

SCREENSHOT_DIR="${HOME}/Pictures/Screenshots"
IMG_NAME="Screenshot_$(date '+%Y-%m-%d_%H-%M-%S-%N' | cut -b -23).png"

case $1 in
  --full)
    import -window root "${SCREENSHOT_DIR}/${IMG_NAME}"
    ;;
  --active)
    WIN_ID="$(xprop -root _NET_ACTIVE_WINDOW | cut -d ' ' -f 5)"
    import -window "${WIN_ID}" "${SCREENSHOT_DIR}/${IMG_NAME}"
    ;;
  --select)
    import "${SCREENSHOT_DIR}/${IMG_NAME}"
    ;;
  *)
    printf "Invalid option.\n" >&2
    exit 1
    ;;
esac
