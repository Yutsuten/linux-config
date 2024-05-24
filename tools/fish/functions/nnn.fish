function nnn --wraps=nnn --description 'The unorthodox terminal file manager.'
    if test -f ~/.local/bin/nnn
        source ~/.local/bin/nnn $argv
    else
        command nnn $argv
    end
end
