function bkptool --description 'Backup and restore tool'
    argparse --stop-nonopt 'h/help' 'r/restore' 'g/gpg' -- $argv
    or return

    if set -ql _flag_help
        echo 'Usage: bkptool [-h|--help] [-r|--restore] [-g|--gpg]' >&2
        return 0
    end

    set bkp_dir '/media/hdd1'
    set sync_dirs Documents Music Pictures Videos

    if not lsblk | grep --fixed-strings --quiet $bkp_dir
        echo 'FAIL: External drive not mounted.' >&2
        return 1
    end

    if set -ql _flag_restore
        echo 'Start restore'
        for dir in $sync_dirs
            echo "Syncing $dir"
            rsync --archive --update --delete "$bkp_dir/$dir/" "$HOME/$dir/"
        end
    else
        echo 'Start backup'
        if set -ql _flag_gpg
            echo 'Generate GPG secret keys backup'
            gpg --armor --export-secret-keys 281E7046D5349560 | gpg --output "$HOME/Documents/GPG/gpg-master-keys.asc.gpg" --yes --symmetric -
        end

        echo 'Generate 100% Orange Juice save data backup'
        mkdir /tmp/100OJ_Save_Data
        cp -a ~/.steam/steam/steamapps/common/'100 Orange Juice'/user* /tmp/100OJ_Save_Data
        tar --zstd -cf "$HOME/Documents/Games/100OJ/100OJ_Save_Data.zst" -C /tmp 100OJ_Save_Data
        rm -rf /tmp/100OJ_Save_Data

        for dir in $sync_dirs
            echo "Syncing $dir"
            rsync --archive --update --delete "$HOME/$dir/" "$bkp_dir/$dir/"
        end

        echo 'Backup osu!lazer'
        tar --zstd -cf "$bkp_dir/osu-lazer.tar.zst" -C ~/.local/share osu
    end
    echo 'Finish!'
end
