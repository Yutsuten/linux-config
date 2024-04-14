function process_media --description 'Process photos and music using its metadata in the current directory'
    argparse --max-args 0 'h/help' -- $argv
    set exitcode $status

    if test $exitcode -ne 0 || set --query --local _flag_help
        echo 'Usage: process_media [options]' >&2
        echo >&2
        echo '  Synopsis:' >&2
        echo '    Process photos and music using its metadata in the current directory.' >&2
        echo >&2
        echo '  Options:' >&2
        echo '    -h, --help      Show list of command-line options' >&2
        return 1
    end

    for photo in *.jpg
        if not test -f $photo
            continue
        end
        set newname (exiv2 $photo | sed -nE 's/Image timestamp : ([0-9]{4}):([0-9]{2}):([0-9]{2}) ([0-9]{2}):([0-9]{2}):([0-9]{2})/\1-\2-\3-\4-\5-\6.webp/p')
        if test -n "$newname" -a "$photo" != "$newname"
            convert "$photo" -resize '2000x2000>' -define webp:method=6 "$newname"
            trash-put "$photo"
        end
    end

    for music in *.mp3 *.m4a *.ogg *.opus *.flac
        if not test -f $music
            continue
        end
        set ffprobe_out (mktemp)
        ffprobe $music 2>&1 | sed -e "s/'/_/g" -e 's/"//g' -e 's#/#／#g' > $ffprobe_out

        set disc   (sed -nE 's/^\s*disc\s*:\s*(.*)/\1/p' $ffprobe_out | cut -d / -f 1)
        set track  (sed -nE 's/^\s*track\s*:\s*(.*)/\1/p' $ffprobe_out | cut -d / -f 1)
        set album  (sed -nE 's/^\s*album\s*:\s*(.*)/\1/p' $ffprobe_out)
        set title  (sed -nE 's/^\s*title\s*:\s*(.*)/\1/p' $ffprobe_out)
        set ext    (echo $music | sed -nE 's/^.*\.([a-zA-Z0-9]{2,4})$/\1/p')

        mkdir -p "$album"
        mv $music "$album"/(printf '%02d' $disc)_(printf '%02d' $track)_"$title".$ext
        rm $ffprobe_out
    end
    return 0
end
