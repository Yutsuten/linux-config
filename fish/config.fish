if status is-interactive
    set -gx GPG_TTY (tty)
    set -gx PYENV_ROOT $HOME/.cache/pyenv
    set -g fish_color_user blue
    set -g fish_color_host brmagenta
    set -g fish_color_host_remote yellow
    set -g fish_color_autosuggestion white
    set -g VIRTUAL_ENV_DISABLE_PROMPT true

    alias notes 'nvim -S ~/Desktop/Session.vim'
    alias identify 'identify -precision 3'
    alias ssh 'env TERM=xterm-256color ssh'
    alias vimiv 'vimiv --log-level error'
    alias clear 'clear && neofetch'
    alias ffmpeg 'ffmpeg -hide_banner'
    alias ffprobe 'ffprobe -hide_banner'

    fish_add_path ~/.local/bin $PYENV_ROOT/bin
    pyenv init - | source
end

function fish_greeting
    neofetch
end
