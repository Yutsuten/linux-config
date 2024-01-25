function nnn --wraps=nnn --description 'The unorthodox terminal file manager.'
    if test -n "$NNNLVL" -a "$NNNLVL" -ge 1
        echo 'nnn is already running'
        return
    end
    set shortcuts
    set -a shortcuts 'd:dragdrop'
    set -a shortcuts 'g:-!gpg -d "$nnn"'
    set -a shortcuts 'i:-vimiv'
    set -a shortcuts 'p:-mpv'
    set -a shortcuts 'y:-!wl-copy "$nnn"*'
    set -x NNN_PLUG (string join ';' $shortcuts)

    set bookmarks
    set -a bookmarks 'm:/media'
    set -a bookmarks 'l:/mnt/hdd'
    set -x NNN_BMS (string join ';' $bookmarks)

    set -x NNN_TRASH 1
    command nnn -AeouUT v $argv

    if test -e $HOME/.config/nnn/.lastd
        source $HOME/.config/nnn/.lastd
        rm $HOME/.config/nnn/.lastd
    end
end
