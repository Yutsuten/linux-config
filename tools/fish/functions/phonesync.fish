function phonesync
    set bold (tput bold)
    set reset (tput sgr0)

    argparse --max-args 3 'h/help' 'd/documents' -- $argv
    or return

    if set -ql _flag_help
        echo 'Usage: phonesync [-h|--help] [-d|--documents] [IP_ADDRESS PORT USER]' >&2
        return 0
    end

    set backup ~/Documents/Backup/ Backup/
    set music ~/Music/ Music/
    set pictures ~/Pictures/ Pictures/
    set videos ~/Videos/ Videos/

    if findmnt --types fuse.aft-mtp-mount | grep --fixed-strings --quiet /media/mtp
        set fusedir /media/mtp/SDカード/Sync
    else if findmnt --types fuse.sshfs | grep --fixed-strings --quiet /media/sshfs/android
        set fusedir /media/sshfs/android
    end

    if set -ql fusedir
        set options --recursive --inplace --size-only --delete --omit-dir-times --no-perms --exclude='.*/' --verbose
        echo -s $bold '> Syncing backup' $reset
        rsync $options $fusedir/$backup[2] $backup[1]
        echo
        if set -ql _flag_documents
            echo -s $bold '> Syncing documents' $reset
            tar --zstd --directory ~ --create Documents/ \
                | gpg --encrypt --default-recipient-self > $fusedir/Documents.tar.zst.gpg
        end
        echo
        echo -s $bold '> Syncing musics' $reset
        rsync $options $music[1] $fusedir/$music[2]
        echo
        echo -s $bold '> Syncing pictures' $reset
        rsync $options $pictures[1] $fusedir/$pictures[2]
        echo
        echo -s $bold '> Syncing videos' $reset
        rsync $options $videos[1] $fusedir/$videos[2]
        echo 'Finish!'
        return 0
    else if test (count $argv) -eq 3
        set options --no-symlinks --ignore-time --delete --no-perms --exclude-glob='.*/' --verbose
        echo "Accessing $argv[3]@$argv[1]:$argv[2]"
        lftp -c "
            set cmd:fail-exit true;
            open -p $argv[2] -u $argv[3] $argv[1];
            echo '> Syncing backup';
            mirror $options $backup[2] $backup[1];
            echo '> Syncing music';
            mirror $options --reverse $music[1] $music[2];
            echo '> Syncing pictures';
            mirror $options --reverse $pictures[1] $pictures[2];
            echo '> Syncing videos';
            mirror $options --reverse $videos[1] $videos[2];
        "
        echo 'Finish!'
        return 0
    end
    echo 'FAIL: Phone not accessible.' >&2
    echo 'If using FTP, call with arguments: IP_ADDRESS PORT USER.' >&2
    return 1
end
