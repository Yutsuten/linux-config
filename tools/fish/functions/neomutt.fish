function neomutt --wraps=neomutt --description 'Teaching an Old Dog New Tricks'
    if test -f ~/.local/bin/neomutt
        source ~/.local/bin/neomutt $argv
    else
        command neomutt $argv
    end
end
