function process_photos --description 'Process raw photos from smartphone'
    argparse --max-args 1 'h/help' -- $argv
    or return

    if set -ql _flag_help
        echo 'Process raw photos (copied from smartphone) from current directory into OUTPUT.' >&2
        echo 'Usage: process_photos [-h|--help] [OUTPUT]' >&2
        return 0
    end

    set output_dir $argv[1]
    if not test $output_dir
        set output_dir '.'
    end

    if not test -d $output_dir
        echo "Cannot write into '$output_dir'. The directory does not exist!" >&2
        return 1
    end

    for file in *.jpg
        set newfile (exiv2 "$file" | sed -nE 's/Image timestamp : ([0-9]{4}):([0-9]{2}):([0-9]{2}) ([0-9]{2}):([0-9]{2}):([0-9]{2})/\1-\2-\3-\4-\5-\6/p').webp
        set extra_options
        if echo $file | grep -q 'rotate'
            set extra_options $extra_options '-rotate' (echo "$file" | sed -nE 's/.*rotate(-?[0-9]+).*/\1/p')
        end
        convert "$file" -resize '2000x2000>' -define webp:method=6 -quality 70 $extra_options (path normalize $output_dir/"$newfile")
    end
end
