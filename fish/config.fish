if status is-interactive
  set -U fish_user_paths ~/.local/bin ~/.yarn/bin
  set -gx GPG_TTY $(tty)
  set -gx NNN_OPTS eoxr
  set -gx NNN_PLUG 'd:dragdrop;i:img_shuffle'
end
