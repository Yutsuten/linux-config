#!/bin/sh
# Downloaded and adapted from:
# https://github.com/nsxiv/nsxiv-extra/blob/master/scripts/nsxiv-rifle/nsxiv-rifle

TMPDIR="${TMPDIR:-/tmp}"
tmp="$TMPDIR/sxiv_rifle_$$"

is_img_extension() {
  grep -iE '\.(jpe?g|png|gif|svg|webp|tiff|heif|avif|ico|bmp)$'
}

listfiles() {
  find -L "///${1%/*}" -maxdepth 1 -type f -print |
    is_img_extension | sort | tee "$tmp"
}

open_img() {
  # only go through listfiles() if the file has a valid img extension
  if echo "$1" | is_img_extension >/dev/null 2>&1; then
    trap 'rm -f $tmp' EXIT
    count="$(listfiles "$1" | grep -nF "$1")"
  fi
  if [ -n "$count" ]; then
    sxiv -abin "${count%%:*}" -- < "$tmp"
  else
    # fallback incase file didn't have a valid extension, or we couldn't
    # find it inside the list
    sxiv -- "$@"
  fi
}

[ "$1" = '--' ] && shift
case "$1" in
  "") echo "Usage: ${0##*/} PICTURES" >&2; exit 1 ;;
  /*) open_img "$1" ;;
  "~"/*) open_img "$HOME/${1#"~"/}" ;;
  *) open_img "$PWD/$1" ;;
esac
