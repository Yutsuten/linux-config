function nnn --wraps=nnn --description 'The unorthodox terminal file manager.'
    test -f ~/.local/bin/nnn && source ~/.local/bin/nnn || command nnn
end
