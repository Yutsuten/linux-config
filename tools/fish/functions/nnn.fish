function nnn --wraps=nnn --description 'The unorthodox terminal file manager.'
    if test -n "$NNNLVL" -a "$NNNLVL" -ge 1
        echo 'nnn is already running' >&2
        return 1
    end
    set shortcuts
    set --append shortcuts 'd:dragdrop'
    set --append shortcuts 'i:-vimiv'
    set --append shortcuts 'l:-!less -N "$nnn"*'
    set --append shortcuts 'p:-mpv'
    set --append shortcuts 'y:-!wl-copy "$nnn"*'
    set --export NNN_PLUG (string join ';' $shortcuts)

    set bookmarks
    set --append bookmarks 'm:/media'
    set --append bookmarks 'l:/mnt/hdd'
    set --export NNN_BMS (string join ';' $bookmarks)

    set --export NNN_TRASH 1
    command nnn -AeouUT v $argv

    if test -e "$HOME/.config/nnn/.lastd"
        source "$HOME/.config/nnn/.lastd"
        rm "$HOME/.config/nnn/.lastd"
    end
    return 0
end
