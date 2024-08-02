#!/usr/bin/env fish
argparse --max-args 0 --exclusive 'r,e,s' 'h/help' 'r/random' 'e/restore' 's/set=' -- $argv
set exitcode $status

function script_help
    echo 'Usage: wallpaper [options]' >&2
    echo >&2
    echo '  Synopsis:' >&2
    echo '    Set wallpaper in sway.' >&2
    echo >&2
    echo '  Options:' >&2
    echo '    -h, --help       Show list of command-line options' >&2
    echo '    -r, --random     Change to a random wallpaper' >&2
    echo '    -e, --restore    Restore the last wallpaper used' >&2
    echo '    -s, --set FILE   Temporarily set an arbitrary wallpaper' >&2
end

if test $exitcode -ne 0 || set --query --local _flag_help
    script_help
    return $exitcode
end

set history_file_path ~/.cache/wallpaper
set tmp_wallpaper /tmp/tmp_wallpaper.*

function random_wallpaper
    set tmp_all_wallpapers (mktemp)
    cd $WALLPAPERS_PATH
    printf '%s\n' *.* > $tmp_all_wallpapers
    if not test -s $tmp_all_wallpapers
        rm --force -- $tmp_all_wallpapers
        echo "No wallpapers found at WALLPAPERS_PATH '$WALLPAPERS_PATH'." >&2
        return 1
    end
    set tmp_new_history (mktemp)
    test -f $history_file_path || echo '' > $history_file_path
    head -n (math --scale 0 (count < $tmp_all_wallpapers) / 2) $history_file_path > $tmp_new_history
    set candidates (comm -23 $tmp_all_wallpapers (sort $tmp_new_history | psub))
    set elected $candidates[(random 1 (count $candidates))]
    sed "1i $elected" $tmp_new_history > $history_file_path
    swaymsg output '*' bg $WALLPAPERS_PATH/$elected fill
    rm --force -- $tmp_all_wallpapers $tmp_new_history
end

function delete_tmp_wallpaper
    if test -n "$tmp_wallpaper"
        rm --force -- $tmp_wallpaper
    end
end

if set --query --local _flag_random
    delete_tmp_wallpaper
    random_wallpaper
else if set --query --local _flag_restore
    delete_tmp_wallpaper
    if not test -s $history_file_path
        random_wallpaper
        return $status
    end
    set target $WALLPAPERS_PATH/(head -n 1 $history_file_path)
    if not test -f $target
        random_wallpaper
        return $status
    end
    swaymsg output '*' bg $target fill
else if set --query --local _flag_set
    delete_tmp_wallpaper
    set target_wallpaper (path resolve $_flag_set)
    if not swaymsg output '*' bg $target_wallpaper fill
        set tmp_wallpaper /tmp/tmp_wallpaper(path extension $_flag_set)
        cp $target_wallpaper $tmp_wallpaper
        swaymsg output '*' bg $tmp_wallpaper fill
    end
else
    echo 'One option must be provided.' >&2
    script_help
    return 1
end
