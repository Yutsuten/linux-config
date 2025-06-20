function git-switch --description 'Change git branch using a fuzzy finder'
    argparse h/help -- $argv
    set exitcode $status

    if test $exitcode -ne 0 || set --query --local _flag_help
        echo 'Usage: git-switch [options]' >&2
        echo >&2
        echo '  Synopsis:' >&2
        echo '    Change git branch using a fuzzy finder.' >&2
        echo >&2
        echo '  Options:' >&2
        echo '    -h, --help      Show list of command-line options' >&2
        return $exitcode
    end

    if not test -d .git
        echo 'Not in a git repository.' >&2
        return 1
    end

    set selection (git for-each-ref --format='%(refname:short)' refs/heads/ | fzf --height=10 --style=minimal) || return
    git switch $selection
end
