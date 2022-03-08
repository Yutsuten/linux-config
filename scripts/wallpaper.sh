#!/bin/bash
# ------------------------------ #
# Set wallpaper using xwallpaper #
# ------------------------------ #

set -e
set -u
set -o pipefail

WALLPAPER_DIR="${HOME}/Pictures/Wallpapers/Active"
SAVED_WALLPAPER="${HOME}/.cache/wallpaper"

print_options() {
  printf "%s\n" 'Usage:' >&2
  printf "  %s\n\n" "wallpaper [option]" >&2
  printf "%s\n" 'Options:' >&2
  printf "  %-16s %s\n" '--help' 'Show this help.' >&2
  printf "  %-16s %s\n" '--random' 'Change to a random wallpaper.' >&2
  printf "  %-16s %s\n" '--restore' 'Restore the last wallpaper used.' >&2
}

if [[ "$#" -ne 1 ]]; then
  printf "%s\n\n" 'A single option must be provided.' >&2
  print_options
  exit 1
fi

case $1 in
  --help)
    print_options
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
  --restore)
    xargs -0 xwallpaper --zoom < "${SAVED_WALLPAPER}"
    ;;
  *)
    printf "Invalid option.\n" >&2
    print_options
    exit 1
    ;;
esac
