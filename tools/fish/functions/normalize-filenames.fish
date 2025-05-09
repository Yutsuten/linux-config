function normalize-filenames --description 'Increase compatibility of file names recursively in the current directory'
    argparse --max-args 0 h/help -- $argv
    set exitcode $status

    if test $exitcode -ne 0 || set --query --local _flag_help
        echo 'Usage: normalize-filenames [options]' >&2
        echo >&2
        echo '  Synopsis:' >&2
        echo '    Increase compatibility of file names recursively in the current directory.' >&2
        echo >&2
        echo '  Options:' >&2
        echo '    -h, --help      Show list of command-line options' >&2
        return $exitcode
    end

    set bold (tput bold)
    set reset (tput sgr0)
    set count 0

    if test (count (string split '/' $PWD)) -le 3
        echo 'Current directory may affect too many files.'
        if not gum confirm 'Are you sure?' --show-output
            return 1
        end
    end

    for file in **/*
        if not test -f $file
            continue
        end
        set normalized (echo $file | tr -d '|?*<":>+[]\'\\\\' | tr ' ' '_')
        set normalized_dir (dirname "$normalized")
        if test "$file" != "$normalized"
            mkdir -p "$normalized_dir"
            mv $file "$normalized"
            echo "Before : $file"
            echo "After  : $normalized"
            echo
            set count (math $count + 1)
        end
    end
    find . -type d -empty -delete
    echo $bold"Renamed $count files!"$reset
    return 0
end
