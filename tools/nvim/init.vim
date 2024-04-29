scriptencoding utf-8

" Settings
set completeopt-=preview
set expandtab
set fileencodings=ucs-bom,utf-8,sjis,latin1
set grepprg=grep\ -In\ $*\ /dev/null
set list listchars=tab:›\ ,trail:˽,nbsp:˲
set mouse=nv
set nohlsearch
set noshowmode
set number
set sessionoptions-=buffers
set sessionoptions-=folds
set sessionoptions-=help
set shada=\"0,'0,/100,:100,@0,f0,h,s4
set shiftwidth=2
set signcolumn=no
set softtabstop=2
set tabstop=4
set wildignorecase

let g:loaded_netrwPlugin = 1
let g:netrw_banner = 0
let g:mapleader = '\'

" Commands
command -nargs=+ Ggrep cex system('git grep -In --column --untracked ' .. <q-args>)
command -nargs=+ Indent call s:SetIndent(<f-args>)
command -nargs=0 Terminal bot 12split +terminal | set winfixheight | startinsert

" Shortcuts
nnoremap <C-s> :update<CR>
nnoremap <silent> <C-1> :tabnext 1<CR>
nnoremap <silent> <C-2> :tabnext 2<CR>
nnoremap <silent> <C-3> :tabnext 3<CR>
nnoremap <silent> <C-4> :tabnext 4<CR>
nnoremap <silent> <C-5> :tabnext 5<CR>
nnoremap <silent> <C-6> :tabnext 6<CR>
nnoremap <silent> <C-7> :tabnext 7<CR>
nnoremap <silent> <C-8> :tabnext 8<CR>
nnoremap <silent> <C-9> :tabnext 9<CR>
nnoremap <silent> <C-0> :tabnext 10<CR>
nnoremap <leader>s :syntax sync fromstart<CR>
nnoremap <leader>w :%s/\s\+$//g<CR>
nnoremap <leader>% :let @+ = expand('%:~:.')<CR>
nnoremap <leader>$ :let @+ = fnamemodify(getcwd(), ':~')<CR>

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
