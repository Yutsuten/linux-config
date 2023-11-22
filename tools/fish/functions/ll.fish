function ll --wraps=ls --description 'List contents of directory using long format'
    command ls -l --human-readable --literal --classify=auto --group-directories-first --sort=v --color=auto $argv
end
