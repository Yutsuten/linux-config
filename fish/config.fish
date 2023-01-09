if status is-interactive
    fish_add_path ~/.local/bin

    set -gx GPG_TTY (tty)
    set -g fish_color_user blue
    set -g fish_color_host brmagenta
    set -g fish_color_host_remote yellow

    alias identify 'identify -precision 3'
    alias ssh 'env TERM=xterm-256color ssh'
end

function fish_greeting
    neofetch
end
