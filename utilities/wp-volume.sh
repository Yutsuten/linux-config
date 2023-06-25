#!/bin/bash

set -e
set -u
set -o pipefail

if [[ "$#" -ne 1 ]] || [[ $1 == -h ]]; then
  echo "Usage: $0 [toggle-mute|VOL[%][-/+]]" >&2
  exit 1
fi

if [[ $1 == toggle-mute ]]; then
  wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
else
  wpctl set-volume @DEFAULT_AUDIO_SINK@ "$1"
fi

read -ra state < <(wpctl get-volume @DEFAULT_AUDIO_SINK@)

if [[ ${#state[@]} -eq 3 ]]; then
  notify-send --replace-id 9999 --app-name wp-volume --icon audio-volume-muted-symbolic --urgency low 'Volume: Muted'
else
  volume=$(python -c "print(int(${state[1]} * 100))")
  if [[ ${volume} -le 33 ]]; then
    icon=audio-volume-low-symbolic
  elif [[ ${volume} -le 66 ]]; then
    icon=audio-volume-medium-symbolic
  else
    icon=audio-volume-high-symbolic
  fi
  notify-send --replace-id 9999 --app-name wp-volume --icon ${icon} --urgency low -h "int:value:${volume}" "Volume: ${volume}%"
fi
