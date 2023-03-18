function ls --wraps=ls --description 'List contents of directory'
    command ls --literal --classify=auto --group-directories-first --sort=v --color=auto $argv
end
