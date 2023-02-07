function nnn --wraps=nnn --description 'The unorthodox terminal file manager.'
    if test -n "$NNNLVL" -a "$NNNLVL" -ge 1
        echo 'nnn is already running'
        return
    end
    set -gx NNN_PLUG 'd:dragdrop;i:img_shuffle'
    set -gx NNN_BMS 'r:/mnt/hdd/recording;s:/mnt/sshfs'
    command nnn -eorT v $argv

    if test -e $HOME/.config/nnn/.lastd
        source $HOME/.config/nnn/.lastd
        rm $HOME/.config/nnn/.lastd
    end
end
