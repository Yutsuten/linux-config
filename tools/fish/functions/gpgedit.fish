function gpgedit --argument-names FILE --description 'Edit gpg files using nvim'
    argparse --min-args 1 --max-args 1 'h/help' -- $argv
    set exitcode $status

    function help
        echo 'Usage: gpgedit [-h|--help] FILE' >&2
        echo >&2
        echo '  Synopsis:' >&2
        echo '    Edit gpg files using nvim.' >&2
        echo >&2
        echo '  Options:' >&2
        echo '    -h, --help      Show list of command-line options' >&2
        echo >&2
        echo '  Arguments:' >&2
        echo '    FILE: The gpg file to be edited' >&2
    end

    if test $exitcode -ne 0 || set --query --local _flag_help
        help
        return 1
    end

    if not test -f $argv[1]
        echo "$argv[1] is not a file." >&2
        help
        return 1
    end

    set temp_file (mktemp --tmpdir (path basename $argv[1]).XXXXXXX)
    if not gpg --decrypt $argv[1] > $temp_file
        echo "$argv[1] is not a gpg file" >&2
        rm -f $temp_file
        return 1
    end
    set before_shasum "$(shasum $temp_file)"
    nvim -ni NONE $temp_file
    if test $before_shasum = "$(shasum $temp_file)"
        echo "File was not edited." >&2
        rm -f $temp_file
        return 0
    end
    gpg --encrypt --default-recipient-self --output - $temp_file > $argv[1] && rm -f $temp_file
end
