sleep 0.2
pactl set-default-sink "$(pactl list short sinks | sed -nE 's/^.*(alsa_output.+analog-stereo[^\s\t]*).*$/\1/p')"
sleep 0.1
wpctl set-volume @DEFAULT_AUDIO_SINK@ 50%
