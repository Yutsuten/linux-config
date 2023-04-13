function nnn --wraps=nnn --description 'The unorthodox terminal file manager.'
    if test -n "$NNNLVL" -a "$NNNLVL" -ge 1
        echo 'nnn is already running'
        return
    end
    set -gx NNN_PLUG 'c:-!wl-copy "$nnn"*;d:dragdrop;i:-vimiv;p:-mpv'
    set -gx NNN_BMS 'm:/media;l:/mnt/hdd'
    set -gx NNN_TRASH 1
    command nnn -eorAuT v $argv

    if test -e $HOME/.config/nnn/.lastd
        source $HOME/.config/nnn/.lastd
        rm $HOME/.config/nnn/.lastd
    end
end
