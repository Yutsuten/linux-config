function bkptool --description 'Backup and restore user files'
    argparse --max-args 0 'h/help' 'r/restore' 'o/osu' -- $argv
    set exitcode $status

    if test $exitcode -ne 0 || set --query --local _flag_help
        echo 'Usage: bkptool [options]' >&2
        echo >&2
        echo '  Synopsis:' >&2
        echo '    Backup and restore user files.' >&2
        echo >&2
        echo '  Options:' >&2
        echo '    -h, --help      Show list of command-line options' >&2
        echo '    -r, --restore   Restore files from backup' >&2
        echo '    -o, --osu       Include osu!lazer data to backup' >&2
        return 1
    end

    set bold (tput bold)
    set reset (tput sgr0)

    set bkp_dir '/media/hdd1'
    set sync_dirs Desktop Documents Music Pictures Videos .password-store

    if not lsblk | grep --fixed-strings --quiet $bkp_dir
        echo 'FAIL: External drive not mounted.' >&2
        return 1
    end

    if set --query --local _flag_restore
        mkdir -p ~/.local/share ~/.local/aur ~/.config
        for dir in $sync_dirs
            echo $bold"Restore $dir"$reset
            rsync --archive --update --delete --verbose "$bkp_dir/$dir/" "$HOME/$dir/"
        end
        echo $bold'Restore anki'$reset
        tar --zstd -xf "$bkp_dir/anki.tar.zst" -C ~/.local/share
        echo $bold'Restore aur packages list'$reset
        cp -a "$bkp_dir/aur_packages" ~/.local/aur/packages
        echo $bold'Restore fcitx5'$reset
        tar --zstd -xf "$bkp_dir/fcitx5.tar.zst" -C ~/.config
        echo $bold'Restore local environment variables'$reset
        cp -a "$bkp_dir/environment" ~/.local/environment
        echo $bold'Restore osu!lazer'$reset
        tar --zstd -xf "$bkp_dir/osu-lazer.tar.zst" -C ~/.local/share
        echo $bold'Restore thunderbird'$reset
        tar --zstd -xf "$bkp_dir/thunderbird.tar.zst" -C ~
    else
        # Check for empty directories
        set empty 0
        for dir in $sync_dirs
            test -z (find "$HOME/$dir" -maxdepth 0 -empty) || set empty 1
        end
        test -z (find ~/.local/share/Anki2 -maxdepth 0 -empty) || set empty 1
        test -z (find ~/.config/fcitx5 -maxdepth 0 -empty) || set empty 1
        test -z (find ~/.local/share/osu -maxdepth 0 -empty) || set empty 1
        test -z (find ~/.thunderbird -maxdepth 0 -empty) || set empty 1
        test -z (find ~/.steam/steam/steamapps/common/'100 Orange Juice' -maxdepth 0 -empty) || set empty 1
        if test $empty -eq 1
            echo 'There is empty directory. Abort.' >&2
            return 1
        end

        # Start backup
        for dir in $sync_dirs
            echo $bold"Backup $dir"$reset
            rsync --archive --update --delete --verbose "$HOME/$dir/" "$bkp_dir/$dir/"
        end
        echo $bold'Backup anki'$reset
        tar --zstd -cf "$bkp_dir/anki.tar.zst" -C ~/.local/share Anki2
        echo $bold'Backup aur packages list'$reset
        cp -a ~/.local/aur/packages "$bkp_dir/aur_packages"
        echo $bold'Backup fcitx5'$reset
        tar --zstd -cf "$bkp_dir/fcitx5.tar.zst" -C ~/.config fcitx5
        echo $bold'Backup local environment variables'$reset
        cp -a ~/.local/environment "$bkp_dir/environment"
        if set --query --local _flag_osu
            echo $bold'Backup osu!lazer'$reset
            tar --zstd -cf "$bkp_dir/osu-lazer.tar.zst" -C ~/.local/share osu
        end
        echo $bold'Backup thunderbird'$reset
        tar --zstd -cf "$bkp_dir/thunderbird.tar.zst" -C ~ .thunderbird
        echo $bold'Backup 100% Orange Juice'$reset
        mkdir /tmp/100OJ_Save_Data
        cp -a ~/.steam/steam/steamapps/common/'100 Orange Juice'/user* /tmp/100OJ_Save_Data
        tar --zstd -cf "$bkp_dir/100OJ_Save_Data.tar.zst" -C /tmp 100OJ_Save_Data
        rm -rf /tmp/100OJ_Save_Data
    end
    echo $bold'Finish!'$reset
    return 0
end
