function normalize_filenames --description 'Increase compatibility of file names recursively in the current directory'
    argparse --max-args 0 'h/help' -- $argv
    set exitcode $status

    if test $exitcode -ne 0 || set --query --local _flag_help
        echo 'Usage: normalize_filenames [options]' >&2
        echo >&2
        echo '  Synopsis:' >&2
        echo '    Increase compatibility of file names recursively in the current directory.' >&2
        echo >&2
        echo '  Options:' >&2
        echo '    -h, --help      Show list of command-line options' >&2
        return 1
    end

    for file in **/*
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
