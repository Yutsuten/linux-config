function m3ucheck --description 'Check contents of m3u files for issues'
    argparse h/help -- $argv
    set exitcode $status

    if test $exitcode -ne 0 -o (count $argv) -eq 0 || set --query --local _flag_help
        echo 'Usage: m3ucheck [options]' >&2
        echo >&2
        echo '  Synopsis:' >&2
        echo '    Check contents of m3u files for issues.' >&2
        echo >&2
        echo '  Options:' >&2
        echo '    -h, --help      Show list of command-line options' >&2
        return $exitcode
    end

    set exit_code 0
    for m3u_file in $argv
        if not test -f $m3u_file
            echo "$m3u_file is not a file"
            return 1
        end
        if not test (path extension $m3u_file) = .m3u
            echo "$m3u_file is not a .m3u file"
            return 1
        end
        while read --line music_path
            if not test -f $music_path
                echo "$m3u_file: $music_path not found"
                set exit_code (math $exit_code + 1)
            end
        end <$m3u_file
    end
    return $exit_code
end
