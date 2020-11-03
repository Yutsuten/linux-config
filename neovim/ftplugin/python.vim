setlocal shiftwidth=4
setlocal softtabstop=4
setlocal colorcolumn=81

highlight ColorColumn ctermbg=0

let b:ale_linters = ['flake8', 'pylint', 'pyls']
let b:ale_fixers = ['isort', 'yapf']

function! s:Pydoc()
  let iskeyword = &iskeyword
  setlocal iskeyword +=.
  let selected_word = expand('<cword>')
  let &iskeyword = iskeyword
  call g:OutputToPreviewWindow(system('pydoc ' . selected_word))
endfunction

command! -nargs=0 Pydoc call s:Pydoc()

nnoremap <leader>k :Pydoc<CR>
noremap <leader>cc :s/\v^(\s*)(.+)/\1# \2/<CR>
noremap <leader>cu :s/\v(\s*)# (.+)/\1\2/<CR>
