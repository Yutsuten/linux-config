function clicker --description 'Auto clicker for Sway'
    argparse --max-args 0 'h/help' -- $argv
    set exitcode $status

    if test $exitcode -ne 0 || set --query --local _flag_help
        echo 'Usage: clicker [options] SECONDS' >&2
        echo >&2
        echo '  Synopsis:' >&2
        echo '    Auto clicker for Sway.' >&2
        echo >&2
        echo '  Options:' >&2
        echo '    -h, --help      Show list of command-line options' >&2
        return $exitcode
    end

    sleep $argv[1] || return
    while true
        swaymsg seat seat0 cursor press button1
        swaymsg seat seat0 cursor release button1
        sleep $argv[1]
    end
    return 0
end
