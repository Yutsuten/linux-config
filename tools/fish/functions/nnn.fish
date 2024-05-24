function nnn --wraps=nnn --description 'The unorthodox terminal file manager.'
    test -f ~/.local/bin/nnn && ~/.local/bin/nnn $argv || command nnn $argv
end
