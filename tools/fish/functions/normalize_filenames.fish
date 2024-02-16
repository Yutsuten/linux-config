function normalize_filenames --description 'Normalize filenames recursively (to be more compatible)'
    argparse --max-args 1 'h/help' -- $argv
    set exitcode $status

    if test $exitcode -ne 0 || set --query --local _flag_help
        echo 'Usage: normalize_filenames [options] [TARGET]' >&2
        echo '  -h, --help      Show list of command-line options' >&2
        return 1
    end

    set target .
    if test -n "$argv"
        set target "$argv"
    end
    if not test -d "$target"
        echo 'TARGET must be a valid directory' >&2
        echo 'Usage: normalize_filenames [options] [TARGET]' >&2
        echo '  -h, --help      Show list of command-line options' >&2
        return 1
    end

    for file in "$target"/**/*
        if not test -f $file
            continue
        end
        set normalized (echo $file | tr -d '|?*<":>+[]\'\\\\' | tr ' ' '_')
        set normalized_dir (dirname "$normalized")
        if test "$file" != "$normalized"
            mkdir -p "$normalized_dir"
            mv -v $file "$normalized"
        end
    end
    find . -type d -empty -delete
    return 0
end
