function phonesync
    if not findmnt --types fuse.aft-mtp-mount | grep --fixed-strings --quiet /media/mtp
        echo 'FAIL: Phone not mounted.' >&2
        return 1
    end

    set options --inplace --omit-dir-times --no-perms --update --recursive --delete

    echo 'Sync notes to phone'
    rsync $options ~/Documents/Notes/ /media/mtp/SDカード/Documents/Notes/

    echo 'Sync photos to phone'
    rsync $options ~/Pictures/Photos/ /media/mtp/SDカード/DCIM/Camera/

    echo 'Sync videos to phone'
    rsync $options ~/Videos/Camera/ /media/mtp/SDカード/Movies/

    echo 'Finish!'
end
