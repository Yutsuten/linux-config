#!/bin/bash
# ------------------------------------------------- #
# Customization of termdown                         #
# ln -sf $(pwd)/countdown.sh ~/.local/bin/countdown #
# ------------------------------------------------- #

set -e
set -u

termdown -B -f doh "$1"
fellow finish
