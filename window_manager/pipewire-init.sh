#!/usr/bin/sh

sleep 0.5
pactl set-default-sink alsa_output.pci-0000_2f_00.4.analog-stereo

sleep 1
pactl load-module module-loopback sink=mix source=alsa_output.pci-0000_2f_00.4.analog-stereo.monitor
pactl load-module module-loopback sink=mix channels=2 channel_map=mono,mono source=alsa_input.pci-0000_2f_00.4.analog-stereo
