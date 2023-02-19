#!/bin/bash

if [[ -f /tmp/cursor_move ]]; then
    killall cursor_move
    rm /tmp/cursor_move
    pkill -RTMIN+1 waybar
else
    cursor_move &
    echo '' > /tmp/cursor_move
    pkill -RTMIN+1 waybar
fi
