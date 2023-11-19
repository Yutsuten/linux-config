function bkptool --description 'Backup and restore tool'
    argparse --max-args 0 'h/help' 'r/restore' 'o/osu' -- $argv
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
        for dir in $sync_dirs
            echo "Restore $dir"
            rsync --archive --update --delete "$bkp_dir/$dir/" "$HOME/$dir/"
        end
        echo 'Restore osu!lazer'
        mkdir -p ~/.local/share
        tar --zstd -xf "$bkp_dir/osu-lazer.tar.zst" -C ~/.local/share
        echo 'Restore thunderbird'
        tar --zstd -xf "$bkp_dir/thunderbird.tar.zst" -C ~
    else
        # Check for empty directories
        set empty 0
        for dir in $sync_dirs
            test -z (find "$dir" -maxdepth 0 -empty) || set empty 1
        end
        test -z (find ~/.local/share/osu -maxdepth 0 -empty) || set empty 1
        test -z (find ~/.steam/steam/steamapps/common/'100 Orange Juice' -maxdepth 0 -empty) || set empty 1
        if test $empty -eq 1
            echo 'There is empty directory. Abort.' >&2
            return 1
        end

        # Start backup
        for dir in $sync_dirs
            echo "Backup $dir"
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
