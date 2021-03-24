let b:ale_linters = ['jshint', 'eslint']
let b:ale_fixers = ['eslint']

noremap <leader>cc :s/\v^(\s*)(.+)/\1\/\/ \2/<CR>
noremap <leader>cu :s/\v(\s*)\/\/ (.+)/\1\2/<CR>
