#!/usr/bin/env fish

switch $argv[1]
    case '*.gpg'
        rm --force -- $argv[2]
end
