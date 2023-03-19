function ll --wraps=ls --description 'List contents of directory using long format'
    echo "Temporarily disabled. Use 'lo' instead."
    return 1
    command ls -l --human-readable --literal --classify=auto --group-directories-first --sort=v --color=auto $argv
end
