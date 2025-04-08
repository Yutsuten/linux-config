function passgen --argument-names ALLOWED_CHARS LENGTH --description 'Generate random passwords'
    argparse --max-args 2 h/help -- $argv
    set exitcode $status

    function help --argument-names ALLOWED_CHARS LENGTH
        echo 'Usage: passgen [-h|--help] [ALLOWED_CHARS] [LENGTH]' >&2
        echo >&2
        echo '  Synopsis:' >&2
        echo '    Generate random passwords.' >&2
        echo >&2
        echo '  Options:' >&2
        echo '    -h, --help      Show list of command-line options' >&2
        echo >&2
        echo '  Arguments:' >&2
        echo "    ALLOWED_CHARS: Default to '$ALLOWED_CHARS' (all letters, numbers and symbols)" >&2
        echo "    LENGTH: Default to $LENGTH" >&2
    end

    set DEFAULT_ALLOWED_CHARS '!-~'
    set DEFAULT_LENGTH 25

    if test $exitcode -ne 0 || set --query --local _flag_help
        help $DEFAULT_ALLOWED_CHARS $DEFAULT_LENGTH
        return $exitcode
    end

    if not test "$ALLOWED_CHARS"
        set ALLOWED_CHARS $DEFAULT_ALLOWED_CHARS
    end

    if test "$LENGTH" && not string match --quiet --regex '^[0-9]+$' "$LENGTH"
        echo 'Error: LENGTH is not a number!' >&2
        echo >&2
        help $DEFAULT_ALLOWED_CHARS $DEFAULT_LENGTH
        return 1
    else if not test "$LENGTH"
        set LENGTH $DEFAULT_LENGTH
    end

    tr -dc $ALLOWED_CHARS </dev/urandom | head -c$LENGTH
end
