#!/bin/bash
# ------------------------------ #
# Set wallpaper using xwallpaper #
# ------------------------------ #

set -e
set -u
set -o pipefail

WALLPAPER_DIR="${HOME}/Pictures/Wallpapers/Active"
SAVED_WALLPAPER="${HOME}/.cache/wallpaper"

case $1 in
  --restore)
    xargs -0 xwallpaper --zoom < "${SAVED_WALLPAPER}"
    ;;
  --random)
    current_image=$(cat "${SAVED_WALLPAPER}")
    random_image=${current_image}
    while [[ "${random_image}" == "${current_image}" ]]; do
      random_image=$(printf '%s\n' "${WALLPAPER_DIR}"/* | shuf -n 1)
    done
    printf '%s' "${random_image}" > "${SAVED_WALLPAPER}"
    xwallpaper --zoom "${random_image}"
    ;;
  *)
    printf "Invalid option.\n" >&2
    exit 1
    ;;
esac
