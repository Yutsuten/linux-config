if status is-interactive
    set -gx GPG_TTY $(tty)
    set -gx NNN_OPTS eoxr
    set -gx NNN_PLUG 'd:dragdrop;i:img_shuffle'

    set -U fish_user_paths ~/.local/bin ~/.yarn/bin
    set -U fish_greeting
    set -g fish_color_user blue
    set -g fish_color_host brmagenta
    set -g fish_color_host_remote yellow

    alias ssh 'env TERM=xterm-256color ssh'
end
