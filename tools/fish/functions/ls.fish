function ls --wraps=ls --description 'List contents of directory'
    command ls --literal --classify --group-directories-first --sort=v --color=auto $argv
end
