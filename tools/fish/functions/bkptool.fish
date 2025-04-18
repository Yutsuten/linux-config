function bkptool --description 'Backup and restore user files'
    argparse --max-args 0 h/help r/restore -- $argv
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
        return $exitcode
    end

    set bold (tput bold)
    set reset (tput sgr0)

    set bkp_dir /media/hdd1
    set sync_dirs Desktop Documents Music Pictures Videos Encrypted .password-store

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

        echo $bold"Restore Linux.tar.zst.gpg"$reset
        gpg --decrypt "$bkp_dir/Linux.tar.zst.gpg" \
            | tar --extract --zstd --directory ~
    else
        # Pacman backup
        pacman -Qqe >~/Documents/Backup/Computer/pacman_(date '+%Y-%m-%d').list
        groups (whoami) >~/Documents/Backup/Computer/groups.list

        function trim_old_backup
            set keep_count $argv[1]
            set cur 0
            printf '%s\0' $argv[2..] | sort --zero-terminated --reverse | while read --null filename
                set cur (math $cur + 1)
                if test $cur -gt $keep_count
                    rm --force --verbose -- $filename
                end
            end
        end

        trim_old_backup 10 ~/Documents/Backup/Computer/pacman_*.list

        # Sync backup
        for dir in $sync_dirs
            if test -z (find "$HOME/$dir" -maxdepth 0 -empty)
                echo $bold"Backup $dir"$reset
                rsync --archive --update --copy-links --delete --verbose "$HOME/$dir/" "$bkp_dir/$dir/"
            else
                echo $bold"Skip empty $dir"$reset
            end
        end

        # Compressed encrypted backup
        echo $bold'Generate Linux.tar.zst.gpg'$reset
        tar --create --zstd --directory ~ .config/backup.list (read --null <~/.config/backup.list) (find ~/Projects -type d -name .zellij | string replace ~/ '') \
            | gpg --encrypt --default-recipient-self >~/Documents/Backup/Computer/Linux.tar.zst.gpg

        echo $bold'Backup Linux.tar.zst.gpg'$reset
        cp --archive ~/Documents/Backup/Computer/Linux.tar.zst.gpg "$bkp_dir/Linux.tar.zst.gpg"
    end
    echo $bold'Finish!'$reset
    return 0
end
