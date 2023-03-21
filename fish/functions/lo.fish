function lo --wraps=ls --description 'List contents of directory using long format'
    command ls -o --human-readable --literal --classify=auto --group-directories-first --sort=v --color=auto $argv
end