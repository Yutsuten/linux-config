function phonesync
    set bold (tput bold)
    set reset (tput sgr0)

    if findmnt --types fuse.aft-mtp-mount | grep --fixed-strings --quiet /media/mtp
        set options --recursive --inplace --size-only --delete --omit-dir-times --no-perms --verbose
        echo -s $bold '> Syncing notes' $reset
        rsync $options ~/Documents/Notes/ /media/mtp/SDカード/Documents/
        echo
        echo -s $bold '> Syncing musics' $reset
        rsync $options ~/Music/ /media/mtp/SDカード/Music/
        echo
        echo -s $bold '> Syncing photos' $reset
        rsync $options ~/Pictures/Photos/ /media/mtp/SDカード/DCIM/Camera/Photos/
        echo
        echo -s $bold '> Syncing videos' $reset
        rsync $options ~/Videos/Camera/ /media/mtp/SDカード/DCIM/Camera/Videos/
        echo 'Finish!'
        return 0
    else if test (count $argv) -eq 3
        echo "Accessing $argv[3]@$argv[1]:$argv[2]"
        lftp -c "
            set cmd:fail-exit true;
            open -p $argv[2] -u $argv[3] $argv[1];
            echo '> Syncing notes';
            mirror --reverse --parallel=10 --only-newer --delete --no-perms --verbose ~/Documents/Notes/ /Documents;
            echo '> Syncing musics';
            mirror --reverse --parallel=10 --only-newer --delete --no-perms --verbose ~/Music/ /Music;
            echo '> Syncing photos';
            mirror --reverse --parallel=10 --only-newer --delete --no-perms --verbose ~/Pictures/Photos/ /DCIM/Camera/Photos;
            echo '> Syncing videos';
            mirror --reverse --parallel=10 --only-newer --delete --no-perms --verbose ~/Videos/Camera/ /DCIM/Camera/Videos;
        "
        echo 'Finish!'
        return 0
    end

    echo 'FAIL: Phone not accessible.' >&2
    echo 'If using FTP, call with arguments: IP_ADDRESS PORT USER.' >&2
    return 1
end
