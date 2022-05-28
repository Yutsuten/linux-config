if status is-interactive
    fish_add_path ~/.local/bin ~/.yarn/bin

    set -gx GPG_TTY $(tty)
    set -gx NNN_OPTS eor
    set -gx NNN_PLUG 'd:dragdrop;i:img_shuffle'

    set -g fish_greeting
    set -g fish_color_user blue
    set -g fish_color_host brmagenta
    set -g fish_color_host_remote yellow

    alias identify 'identify -precision 3'
    alias ssh 'env TERM=xterm-256color ssh'
end
