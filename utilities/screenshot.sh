#!/bin/bash
# ------------------------ #
# Take screenshot in sway. #
# ------------------------ #

set -e
set -u

SCREENSHOT_DIR="${HOME}/Pictures/Screenshots"
IMG_NAME="screenshot_$(date '+%Y%m%d-%H%M%S%N' | cut -b -18).png"

case $1 in
  --full)
    grim "${SCREENSHOT_DIR}/${IMG_NAME}"
    ;;
  --active)
    FOCUSED=$(swaymsg -t get_tree | jq -r 'recurse(.nodes[]?, .floating_nodes[]?) | select(.focused)')
    GEOM=$(echo "$FOCUSED" | jq -r '.rect | "\(.x),\(.y) \(.width)x\(.height)"')
    grim -g "${GEOM}" "${SCREENSHOT_DIR}/${IMG_NAME}"
    ;;
  --select)
    GEOM=$(slurp)
    if [[ -z "${GEOM}" ]]; then
      exit 1
    fi
    grim -g "${GEOM}" "${SCREENSHOT_DIR}/${IMG_NAME}"
    ;;
  *)
    printf "Invalid option.\n" >&2
    exit 1
    ;;
esac
