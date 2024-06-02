function idict --description 'Interactive dictionary'
    argparse 'h/help' -- $argv
    set exitcode $status

    function help
        echo 'Usage: idict [-h|--help]' >&2
        echo >&2
        echo '  Synopsis:' >&2
        echo '    Interactive dictionary.' >&2
        echo >&2
        echo '  Options:' >&2
        echo '    -h, --help      Show list of command-line options' >&2
    end

    if test $exitcode -ne 0 || set --query --local _flag_help
        help
        return $exitcode
    end

    set cur_dict fd-jpn-eng
    set alt_dict fd-eng-jpn
    set user_input ''

    echo 'Hints: Type "t" to toggle, "exit" to exit.'
    echo

    while true
        read --line --prompt-str "$cur_dict> " user_input
        switch $user_input
            case t
                set tmp $cur_dict
                set cur_dict $alt_dict
                set alt_dict $tmp
            case exit
                break
            case quit
                break
            case '*'
                dict -d $cur_dict $user_input
                echo
        end
    end
    return 0
end
