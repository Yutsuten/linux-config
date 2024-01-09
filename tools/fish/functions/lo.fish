function lo --wraps=ls --description 'List contents of directory using long format'
    ls -o --human-readable $argv
end
