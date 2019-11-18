set expandtab
set nohlsearch
set noshowmode
set number
set shiftwidth=4
set softtabstop=4
set tabstop=4
set updatetime=300

let mapleader = '\'

autocmd TermOpen * setlocal bufhidden=hide

function! s:Setindent(val)
  let &shiftwidth = a:val
  let &softtabstop = a:val
  let &tabstop = a:val
endfunction

command! -nargs=1 Indent call s:Setindent(<args>)

nnoremap <leader>r :call jobstart(['make'])<CR>
nnoremap <leader>% :let @+ = @%<CR>
