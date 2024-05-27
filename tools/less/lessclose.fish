#!/usr/bin/fish

switch $argv[1]
    case '*.gpg'
        rm -f -- $argv[2]
end
