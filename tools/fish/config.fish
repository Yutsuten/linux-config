if test -f ~/.local/environment
    export (grep -E '^[^#;].+=.*' ~/.local/environment | xargs -L 1)
end

if test (tty) = '/dev/tty1'
    gsettings set org.gnome.desktop.interface gtk-theme 'Arc'
    gsettings set org.gnome.desktop.interface icon-theme 'Arc'
    gsettings set org.gnome.desktop.interface font-name 'Noto Sans 12'
    gsettings set org.gnome.desktop.interface cursor-theme 'Vimix-cursors'
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    exec sway
end

if status is-interactive
    set -gx GPG_TTY (tty)
    set -gx LESSCLOSE $HOME'/.config/linux/tools/less/lessclose.fish %s %s'
    set -gx LESSOPEN $HOME'/.config/linux/tools/less/lessopen.fish %s'

    set -g CDPATH . $HOME $HOME/Projects
    set -g VIRTUAL_ENV_DISABLE_PROMPT true
    set -g fish_color_autosuggestion white
    set -g fish_color_host brmagenta
    set -g fish_color_host_remote yellow
    set -g fish_color_user blue

    alias clear 'clear && neofetch'
    alias diskusage "lsblk -o 'NAME,FSTYPE,SIZE,FSUSED,FSUSE%,MOUNTPOINTS'"
    alias ffmpeg 'ffmpeg -hide_banner'
    alias ffprobe 'ffprobe -hide_banner'
    alias identify 'identify -precision 3'
    alias n 'nnn'
    alias notes 'nvim -S ~/Desktop/Session.vim'
    alias ssh 'env TERM=xterm-256color ssh'
    alias vimiv 'vimiv --log-level error'

    fish_add_path $HOME/.local/bin
end

function fish_greeting
    if test -z "$NNNLVL"
        neofetch
    end
end
