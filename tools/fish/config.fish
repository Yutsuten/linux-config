fish_add_path $HOME/.local/bin

test -f ~/.local/environment.fish && source ~/.local/environment.fish

set -gx GPG_TTY (tty)
set -gx LESSCLOSE $HOME'/.config/linux/tools/less/lessclose.fish %s %s'
set -gx LESSOPEN $HOME'/.config/linux/tools/less/lessopen.fish %s'
set -gx EDITOR edit
set -gx VISUAL edit

if test (tty) = /dev/tty1 -a -z "$WAYLAND_DISPLAY"
    # Gnome
    gsettings set org.gnome.desktop.interface gtk-theme Arc
    gsettings set org.gnome.desktop.interface icon-theme Arc
    gsettings set org.gnome.desktop.interface font-name 'Noto Sans CJK JP 12'
    gsettings set org.gnome.desktop.interface cursor-theme capitaine-cursors
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

    fzf --fish | source
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
