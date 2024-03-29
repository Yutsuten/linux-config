build() {
  test -r /etc/vtrgb || return
  add_file "$(readlink -e /etc/vtrgb)" /etc/vtrgb
  add_binary setvtrgb
  add_runscript
}

help() {
  cat <<HELPEOF
  This hook calls the setvtrgb program to apply the currently configured
  color scheme during the early boot process. It uses /etc/vtrgb as its
  configuration file.
HELPEOF
}
