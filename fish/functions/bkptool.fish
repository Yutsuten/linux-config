function bkptool --description 'Backup and restore tool'
    argparse --stop-nonopt 'h/help' 'r/restore' 'o/osu' -- $argv
    or return

    if set -ql _flag_help
        echo 'Usage: bkptool [-h|--help] [-r|--restore] [-o|--osu]' >&2
        return 0
    end

    set bkp_dir '/media/hdd1'
    set sync_dirs Desktop Documents Music Pictures Videos .password-store

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
        for dir in $sync_dirs
            echo "Syncing $dir"
            rsync --archive --update --delete "$HOME/$dir/" "$bkp_dir/$dir/"
        end

        if set -ql _flag_osu
            echo 'Backup osu!lazer'
            tar --zstd -cf "$bkp_dir/osu-lazer.tar.zst" -C ~/.local/share osu
        end

        echo 'Backup thunderbird'
        tar --zstd -cf "$bkp_dir/thunderbird.tar.zst" -C ~ .thunderbird

        echo 'Backup 100% Orange Juice'
        mkdir /tmp/100OJ_Save_Data
        cp -a ~/.steam/steam/steamapps/common/'100 Orange Juice'/user* /tmp/100OJ_Save_Data
        tar --zstd -cf "$bkp_dir/100OJ_Save_Data.tar.zst" -C /tmp 100OJ_Save_Data
        rm -rf /tmp/100OJ_Save_Data
    end
    echo 'Finish!'
end
