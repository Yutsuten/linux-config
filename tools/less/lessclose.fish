#!/usr/bin/fish

switch $argv[1]
    case '*.gpg'
        rm --force -- $argv[2]
end
