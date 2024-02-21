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

        echo $bold"Restore LinuxConfigBackup.tar.zst.gpg"$reset
        tar --zstd -xf "$bkp_dir/LinuxConfigBackup.tar.zst.gpg" -C ~

        echo $bold"Restore LinuxDataBackup.tar.zst.gpg"$reset
        tar --zstd -xf "$bkp_dir/LinuxDataBackup.tar.zst.gpg" -C ~
    else
        # Sync - Check for empty directories
        set empty 0
        for dir in $sync_dirs
            test -z (find "$HOME/$dir" -maxdepth 0 -empty) || set empty 1
        end
        if test $empty -eq 1
            echo 'Will not backup empty directory. Abort.' >&2
            return 1
        end

        # Sync - Perform backup
        for dir in $sync_dirs
            echo $bold"Backup $dir"$reset
            rsync --archive --update --delete --verbose "$HOME/$dir/" "$bkp_dir/$dir/"
        end

        # Compressed encrypted backup - Generate files
        set bkp_config .config/backup_config
        while read --line target
            set --append bkp_config $target
        end < ~/.config/backup_config

        set bkp_data .config/backup_data
        while read --line target
            set --append bkp_data $target
        end < ~/.config/backup_data

        echo $bold'Generate encrypted backup of config'$reset
        tar --create --zstd --directory ~ $bkp_config \
          | gpg -e --default-recipient-self > LinuxConfigBackup.tar.zst.gpg

        echo $bold'Generate encrypted backup of data'$reset
        tar --create --zstd --directory ~ $bkp_data \
          | gpg -e --default-recipient-self > LinuxDataBackup.tar.zst.gpg

        # Compressed encrypted backup - Perform backup
        echo $bold'Backup LinuxConfigBackup.tar.zst.gpg'$reset
        cp -a LinuxConfigBackup.tar.zst.gpg "$bkp_dir/LinuxConfigBackup.tar.zst.gpg"

        echo $bold'Backup LinuxDataBackup.tar.zst.gpg'$reset
        cp -a LinuxDataBackup.tar.zst.gpg "$bkp_dir/LinuxDataBackup.tar.zst.gpg"
    end
    echo $bold'Finish!'$reset
    return 0
end
