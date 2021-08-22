#!/bin/bash
# --------------- #
# Enable gamemode #
# --------------- #

set -e

RECORD=0

while getopts ":r" opt; do
  case ${opt} in
    r)
      RECORD=1
      ;;
    *)
      echo "Usage: gamemode [-r]"
      exit 1
  esac
done

killall picom
i3-msg -q bar mode invisible

if (( RECORD )); then
  ffmpeg -f pulse -thread_queue_size 512 -i alsa_output.pci-0000_00_1b.0.analog-stereo.monitor \
    -f x11grab -framerate 60 -probesize 16M -thread_queue_size 512 -video_size 1366x768 -i :0.0 \
    -vcodec libx264rgb -crf 0 -preset ultrafast "${HOME}/Videos/gamemode_$(date '+%Y-%m-%d_%H-%M-%S').mp4"
else
  KEY="\0"
  while [[ ${KEY} != q ]]; do
    read -srn1 KEY
  done
fi

i3-msg -q bar mode dock
picom --daemon || true
