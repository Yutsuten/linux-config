scriptencoding utf-8

" Settings
set completeopt-=preview
set expandtab
set fileencodings=ucs-bom,utf-8,sjis,latin1
set list listchars=tab:›\ ,trail:˽,nbsp:˲
set nohlsearch
set noshowmode
set number
set signcolumn=auto:1
set shiftwidth=2
set softtabstop=2
set tabstop=4
set sessionoptions-=buffers
set sessionoptions+=globals
set wildignorecase

let g:netrw_banner=0
let g:mapleader = '\'

" Commands
command -nargs=+ Indent call s:SetIndent(<f-args>)

" Shortcuts
nnoremap <leader>i :ToggleIndent<CR>
nnoremap <leader>r :Make<CR>
nnoremap <leader>% :let @+ = @%<CR>

noremap <leader>c/ :s/\v^(\s*)(.+)/\1\/\/ \2/<CR>
noremap <leader>u/ :s/\v(\s*)\/\/ (.+)/\1\2/<CR>
noremap <leader>c# :s/\v^(\s*)(.+)/\1# \2/<CR>
noremap <leader>u# :s/\v(\s*)# (.+)/\1\2/<CR>
noremap <leader>c" :s/\v^(\s*)(.+)/\1" \2/<CR>
noremap <leader>u" :s/\v(\s*)" (.+)/\1\2/<CR>
noremap <leader>c- :s/\v^(\s*)(.+)/\1-- \2/<CR>
noremap <leader>u- :s/\v(\s*)-- (.+)/\1\2/<CR>

" Triggers
augroup autocompletion
  autocmd!
  autocmd CompleteDone * pclose
augroup end

augroup terminal
  autocmd!
  autocmd TermOpen * setlocal bufhidden=hide nonumber
augroup end

" Script
function s:SetIndent(size, ...)
  " Indent with [s]pace/[t]ab, default to space
  let &expandtab = (a:0 >= 1 ? a:1 : 'space') !~? '^t'
  " Indent size
  let &softtabstop = a:size
  let &tabstop = a:size
  let &shiftwidth = a:size
endfunction
