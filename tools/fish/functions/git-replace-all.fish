function git-replace-all --description 'Find and replace all in a git repository'
    argparse --ignore-unknown h/help -- $argv
    set exitcode $status

    if test $exitcode -ne 0 -o (count $argv) -ne 2 || set --query --local _flag_help
        echo 'Usage: git-replace-all [options] BEFORE_REGEX REPLACEMENT' >&2
        echo >&2
        echo '  Synopsis:' >&2
        echo '    Find and replace all in a git repository.' >&2
        echo >&2
        echo '  Options:' >&2
        echo '    -h, --help      Show list of command-line options' >&2
        return $exitcode
    end

    if not test -d .git
        echo 'Not in a git repository.' >&2
        return 1
    end

    if string match --quiet --entire --invert / $argv
        git grep --files-with-matches $argv[1] | xargs sed -i "s/$argv[1]/$argv[2]/g"
    else if string match --quiet --entire --invert '#' $argv
        git grep --files-with-matches $argv[1] | xargs sed -i "s#$argv[1]#$argv[2]#g"
    else
        echo 'Cannot escape / and # at the same time' >&2
        return 1
    end
end
