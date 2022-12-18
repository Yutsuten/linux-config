function ll --wraps=exa --description 'List contents of directory using long format'
    command exa -l --group-directories-first --git $argv
end
