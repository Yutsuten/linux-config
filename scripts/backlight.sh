#!/bin/bash
# ------------------ #
# xbacklight wrapper #
# ------------------ #

set -e
set -o pipefail

xbacklight "$@"
xbacklight -get | tr -d '\n' > /tmp/backlight
mv /tmp/backlight /tmp/brightness
