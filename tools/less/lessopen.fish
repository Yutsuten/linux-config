#!/usr/bin/fish

switch $argv[1]
    case '*.gpg'
        set tempfile (mktemp)
        gpg -d $argv[1] > $tempfile
        if test -s $tempfile
            echo $tempfile
        else
            rm -f $tempfile
        end
end
