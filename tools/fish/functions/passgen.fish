function passgen --argument-names ALLOWED_CHARS LENGTH --description 'Generate random passwords'
    argparse --max-args 2 'h/help' -- $argv
    or return

    set DEFAULT_ALLOWED_CHARS '!-~'
    set DEFAULT_LENGTH 25

    function help --argument-names ALLOWED_CHARS LENGTH
        echo 'Usage: passgen [-h|--help] [ALLOWED_CHARS] [LENGTH]' >&2
        echo >&2
        echo '  Defaults:' >&2
        echo "  - ALLOWED_CHARS: '$ALLOWED_CHARS' (all characters, numbers and symbols)" >&2
        echo "  - LENGTH: $LENGTH" >&2
    end

    if set --query --local _flag_help
        help $DEFAULT_ALLOWED_CHARS $DEFAULT_LENGTH
        return 1
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

    tr -dc $ALLOWED_CHARS < /dev/urandom | head -c$LENGTH
end
