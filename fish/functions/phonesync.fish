function phonesync
    if not findmnt --types fuse.aft-mtp-mount | grep --fixed-strings --quiet /media/mtp
        echo 'FAIL: Phone not mounted.' >&2
        return 1
    end

    set bold (tput bold)
    set reset (tput sgr0)
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
end
