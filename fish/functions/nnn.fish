function nnn --wraps=nnn --description 'The unorthodox terminal file manager.'
    if test -n "$NNNLVL" -a "$NNNLVL" -ge 1
        echo 'nnn is already running'
        return
    end
    set -x NNN_PLUG 'c:-!wl-copy "$nnn"*;d:dragdrop;i:-vimiv;p:-mpv'
    set -x NNN_BMS 'm:/media;l:/mnt/hdd'
    set -x NNN_TRASH 1
    command nnn -AeouUT v $argv

    if test -e $HOME/.config/nnn/.lastd
        source $HOME/.config/nnn/.lastd
        rm $HOME/.config/nnn/.lastd
    end
end
