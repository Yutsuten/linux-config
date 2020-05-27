countdown() {
  termdown -B -f doh \
    --exec-cmd 'mpv --really-quiet --volume=67 /usr/share/sounds/Smooth/stereo/count-down.oga' \
    "$1" && \
  fellow finish
}
