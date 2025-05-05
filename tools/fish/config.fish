fish_add_path $HOME/.local/bin

test -f ~/.local/environment.fish && source ~/.local/environment.fish

set -gx GPG_TTY (tty)
set -gx LESSCLOSE "$HOME/.config/less/lessclose.fish %s %s"
set -gx LESSOPEN "$HOME/.config/less/lessopen.fish %s"
set -gx EDITOR edit
set -gx VISUAL edit

set -gx GUM_CHOOSE_CURSOR ' → '
set -gx GUM_CHOOSE_CURSOR_BOLD 1
set -gx GUM_CHOOSE_CURSOR_FOREGROUND 4
set -gx GUM_CHOOSE_HEADER_FOREGROUND 6
set -gx GUM_CHOOSE_SHOW_HELP 0
set -gx GUM_CONFIRM_PROMPT_FOREGROUND 6
set -gx GUM_CONFIRM_SELECTED_BACKGROUND 4
set -gx GUM_CONFIRM_SHOW_HELP 0
set -gx GUM_INPUT_CURSOR_FOREGROUND 4
set -gx GUM_INPUT_CURSOR_MODE static
set -gx GUM_INPUT_HEADER_FOREGROUND 6
set -gx GUM_INPUT_SHOW_HELP 0

if test (tty) = /dev/tty1 -a -z "$WAYLAND_DISPLAY"
    # Gnome
    gsettings set org.gnome.desktop.interface gtk-theme Arc
    gsettings set org.gnome.desktop.interface icon-theme Arc
    gsettings set org.gnome.desktop.interface font-name 'Noto Sans CJK JP 12'
    gsettings set org.gnome.desktop.interface cursor-theme Vimix-cursors
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    # Input Method
    set -gx QT_IM_MODULE fcitx
    set -gx XMODIFIERS @im=fcitx
    # Apps
    set -gx ANKI_WAYLAND 1
    # Start Window Manager
    exec sway &>$HOME/.local/logs/sway.log
end

if status is-interactive
    set -g CDPATH . $HOME $HOME/Projects
    set -g VIRTUAL_ENV_DISABLE_PROMPT true
    set -g fish_color_autosuggestion white
    set -g fish_color_host brmagenta
    set -g fish_color_host_remote yellow
    set -g fish_color_user blue

    abbr --add calc -- 'bc -l'
    abbr --add cpwd -- 'wl-copy (string replace --regex "^$HOME" \~ $PWD)'
    abbr --add diskusage -- "lsblk -o 'NAME,FSTYPE,SIZE,FSUSED,FSUSE%,MOUNTPOINTS'"
    abbr --add ffmpeg -- 'ffmpeg -hide_banner'
    abbr --add ffprobe -- 'ffprobe -hide_banner'
    abbr --add m3ugen -- "find . -type f \( -iname '*.mp3' -o -iname '*.m4a' -o -iname '*.ogg' -o -iname '*.opus' -o -iname '*.flac' \) -printf '%P\n' | sort > NewSongs.m3u"
    abbr --add identify -- 'identify -precision 3'
    abbr --add l1 -- 'ls -N1 --sort=v --group-directories-first'
    abbr --add ll -- 'ls -Nlh --sort=v --group-directories-first'
    abbr --add lo -- 'ls -Noh --sort=v --group-directories-first'
    abbr --add ssh -- 'env TERM=xterm ssh'

    if test -d .venv
        source .venv/bin/activate.fish
    end

    if set --query nnn
        set mimetype (file --mime-type $nnn | string match --regex --groups-only '.*: (image|video)/[a-z]+')
        switch $mimetype
            case image
                echo (tput bold)"> identify -precision 3 '$nnn'"(tput sgr0)
                identify -precision 3 $nnn
            case video
                echo (tput bold)"> ffprobe -hide_banner '$nnn'"(tput sgr0)
                ffprobe -hide_banner $nnn
        end
    end
end

function fish_greeting
    if not set --query NNNLVL
        fastfetch
    end
end

function fish_title
    if set --query SSH_TTY
        echo "Fish $hostname $(prompt_pwd)"
    else
        echo "Fish $(prompt_pwd)"
    end
end
