function phonesync
    set bold (tput bold)
    set reset (tput sgr0)

    argparse --max-args 3 'h/help' 'd/documents' -- $argv
    or return

    if set -ql _flag_help
        echo 'Usage: phonesync [-h|--help] [-d|--documents] [IP_ADDRESS PORT USER]' >&2
        return 0
    end

    set backup_phone ~/Documents/Backup/Phone/ Backup/Phone/
    set backup_computer ~/Documents/Backup/Computer/ Backup/Computer/
    set music ~/Music/ Music/
    set notes ~/Documents/Notes/ Notes/
    set pictures ~/Pictures/ Pictures/
    set videos ~/Videos/ Videos/

    if findmnt --types fuse.aft-mtp-mount | grep --fixed-strings --quiet /media/mtp
        set fusedir /media/mtp/SDカード/Sync
    else if findmnt --types fuse.sshfs | grep --fixed-strings --quiet /media/sshfs/android
        set fusedir /media/sshfs/android
    end

    if set -ql fusedir
        set options --recursive --inplace --size-only --delete --omit-dir-times --no-perms --exclude='.*/' --verbose
        echo -s $bold '(Phone > PC) Syncing backup' $reset
        rsync $options $fusedir/$backup_phone[2] $backup_phone[1]
        echo
        echo -s $bold '(PC > Phone) Syncing backup' $reset
        rsync $options $backup_computer[1] $fusedir/$backup_computer[2]
        echo
        if set -ql _flag_documents
            echo -s $bold '(PC > Phone) Syncing documents' $reset
            tar --zstd --directory ~ --create Documents/ \
                | gpg --encrypt --default-recipient-self > $fusedir/Documents.tar.zst.gpg
        end
        echo
        echo -s $bold '(PC > Phone) Syncing musics' $reset
        rsync $options $music[1] $fusedir/$music[2]
        echo
        echo -s $bold '(PC > Phone) Syncing notes' $reset
        rsync $options $notes[1] $fusedir/$notes[2]
        echo
        echo -s $bold '(PC > Phone) Syncing pictures' $reset
        rsync $options $pictures[1] $fusedir/$pictures[2]
        echo
        echo -s $bold '(PC > Phone) Syncing videos' $reset
        rsync $options $videos[1] $fusedir/$videos[2]
        echo 'Finish!'
        return 0
    else if test -n "$argv"
        set options --no-symlinks --ignore-time --delete --no-perms --exclude-glob='.*/' --verbose
        lftp -c "
            set cmd:fail-exit true;
            open $argv;
            echo '(Phone > PC) Syncing backup';
            mirror $options $backup_phone[2] $backup_phone[1];
            echo '(PC > Phone) Syncing backup';
            mirror $options --reverse $backup_computer[1] $backup_computer[2];
            echo '(PC > Phone) Syncing music';
            mirror $options --reverse $music[1] $music[2];
            echo '(PC > Phone) Syncing notes';
            mirror $options --reverse $notes[1] $notes[2];
            echo '(PC > Phone) Syncing pictures';
            mirror $options --reverse $pictures[1] $pictures[2];
            echo '(PC > Phone) Syncing videos';
            mirror $options --reverse $videos[1] $videos[2];
        "
        echo 'Finish!'
        return 0
    end
    echo 'FAIL: Phone not accessible.' >&2
    echo 'If using FTP or SFTP, add the correct arguments for lftp.' >&2
    return 1
end
