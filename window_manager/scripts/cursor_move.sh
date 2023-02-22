#!/bin/bash

while true; do
  swaymsg seat seat0 cursor move -- 1 0
  sleep 0.100s
  swaymsg seat seat0 cursor move -- -1 0
  sleep 0.100s
done
