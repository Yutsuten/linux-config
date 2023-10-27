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
set sessionoptions-=folds
set sessionoptions-=help
set wildignorecase

let g:loaded_netrwPlugin = 1
let g:netrw_banner = 0
let g:mapleader = '\'

" Commands
command -nargs=+ Indent call s:SetIndent(<f-args>)
command -nargs=? Terminal call s:Terminal(<f-args>)

" Shortcuts
nnoremap <leader>i :ToggleIndent<CR>
nnoremap <leader>r :Make<CR>
nnoremap <leader>s :syntax sync fromstart<CR>
nnoremap <leader>w :%s/\s\+$//g<CR>
nnoremap <leader>% :let @+ = expand('%:~:.')<CR>

vnoremap <leader>c/ :<c-u>execute printf(':''<,''>s/\v\s{%d}/\0\/\/ /', indent(getpos('v')[1]))<CR>
vnoremap <leader>u/ :s/\v(\s*)\/\/ (.*)/\1\2/<CR>
vnoremap <leader>c# :<c-u>execute printf(':''<,''>s/\v\s{%d}/\0# /', indent(getpos('v')[1]))<CR>
vnoremap <leader>u# :s/\v(\s*)# (.*)/\1\2/<CR>
vnoremap <leader>c" :<c-u>execute printf(':''<,''>s/\v\s{%d}/\0" /', indent(getpos('v')[1]))<CR>
vnoremap <leader>u" :s/\v(\s*)" (.*)/\1\2/<CR>
vnoremap <leader>c- :<c-u>execute printf(':''<,''>s/\v\s{%d}/\0-- /', indent(getpos('v')[1]))<CR>
vnoremap <leader>u- :s/\v(\s*)-- (.*)/\1\2/<CR>

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

function s:Terminal(...)
  let l:height = a:0 >= 1 ? a:1 : 12
  execute printf('bot %ssplit +set\ winfixheight\ |\ startinsert term://fish', l:height)
endfunction
