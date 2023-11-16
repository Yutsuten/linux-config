#!/usr/bin/bash

sleep 0.2
pactl set-default-sink "$(pactl list short sinks | sed -nE 's/^.*(alsa_output.+analog-stereo[^\s\t]*).*$/\1/p')"
