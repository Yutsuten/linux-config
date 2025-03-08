#!/usr/bin/env fish

switch $argv[1]
    case '*.gpg'
        set tempfile (mktemp)
        gpg -d $argv[1] >$tempfile
        if test -s $tempfile
            echo $tempfile
        else
            rm --force -- $tempfile
        end
end
