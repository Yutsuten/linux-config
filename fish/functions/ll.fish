function ll --wraps=exa --description 'List contents of directory using long format'
    exa -l --group-directories-first --git $argv
end
