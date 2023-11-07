function phonesync
    set bold (tput bold)
    set reset (tput sgr0)

    set documents ~/Documents/ Documents/
    set music ~/Music/ Music/
    set pictures ~/Pictures/ Pictures/
    set videos ~/Videos/ Videos/

    if findmnt --types fuse.aft-mtp-mount | grep --fixed-strings --quiet /media/mtp
        set options --recursive --inplace --size-only --delete --omit-dir-times --no-perms --exclude='.*/' --verbose
        echo -s $bold '> Syncing documents' $reset
        rsync $options $documents[1] /media/mtp/SDカード/Sync/$documents[2]
        echo
        echo -s $bold '> Syncing musics' $reset
        rsync $options $music[1] /media/mtp/SDカード/Sync/$music[2]
        echo
        echo -s $bold '> Syncing pictures' $reset
        rsync $options $pictures[1] /media/mtp/SDカード/Sync/$pictures[2]
        echo
        echo -s $bold '> Syncing videos' $reset
        rsync $options $videos[1] /media/mtp/SDカード/Sync/$videos[2]
        echo 'Finish!'
        return 0
    else if test (count $argv) -eq 3
        set options --reverse --no-symlinks --ignore-time --delete --no-perms --exclude-glob='.*/' --verbose
        echo "Accessing $argv[3]@$argv[1]:$argv[2]"
        lftp -c "
            set cmd:fail-exit true;
            open -p $argv[2] -u $argv[3] $argv[1];
            echo '> Syncing documents';
            mirror $options $documents[1] /$documents[2];
            echo '> Syncing music';
            mirror $options $music[1] /$music[2];
            echo '> Syncing pictures';
            mirror $options $pictures[1] /$pictures[2];
            echo '> Syncing videos';
            mirror $options $videos[1] /$videos[2];
        "
        echo 'Finish!'
        return 0
    end
    echo 'FAIL: Phone not accessible.' >&2
    echo 'If using FTP, call with arguments: IP_ADDRESS PORT USER.' >&2
    return 1
end
