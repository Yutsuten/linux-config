function bkptool --description 'Backup and restore user files'
    argparse --max-args 0 'h/help' 'r/restore' -- $argv
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

        echo $bold"Restore Linux.tar.zst.gpg"$reset
        gpg --decrypt "$bkp_dir/Linux.tar.zst.gpg" \
            | tar --extract --zstd --directory ~
    else
        # Sync backup
        for dir in $sync_dirs
            if test -z (find "$HOME/$dir" -maxdepth 0 -empty)
                echo $bold"Backup $dir"$reset
                rsync --archive --update --delete --verbose "$HOME/$dir/" "$bkp_dir/$dir/"
            else
                echo $bold"Skip empty $dir"$reset
            end
        end

        # Compressed encrypted backup
        set bkp_linux .config/backup.list
        while read --line target
            set --append bkp_linux $target
        end < ~/.config/backup.list

        echo $bold'Generate Linux.tar.zst.gpg'$reset
        tar --create --zstd --directory ~ $bkp_linux \
          | gpg --encrypt --default-recipient-self > Linux.tar.zst.gpg

        echo $bold'Backup Linux.tar.zst.gpg'$reset
        cp --archive Linux.tar.zst.gpg "$bkp_dir/Linux.tar.zst.gpg"
    end
    echo $bold'Finish!'$reset
    return 0
end
