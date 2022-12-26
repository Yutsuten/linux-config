function passgen --description 'Generate random passwords'
    if test (count $argv) -eq 0 || test $argv[1] = '-h' || test $argv[1] = '--help'
        echo 'Usage: passgen LENGTH [ALLOWED_CHARS|A-Za-z0-9!"#$]' >&2
        return 1
    end
    if test (count $argv) -ne 2
        set ALLOWED_CHARS 'A-Za-z0-9!"#$'
    else
        set ALLOWED_CHARS $argv[2]
    end
    tr -dc $ALLOWED_CHARS < /dev/urandom | head -c$argv[1]
end
