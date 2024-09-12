function nnn --wraps=nnn
    if test -f ~/.local/bin/nnn
        source ~/.local/bin/nnn $argv
    else
        command nnn $argv
    end
end
