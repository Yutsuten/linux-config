scriptencoding utf-8

" Settings
set cdpath=,~,~/Projects
set completeopt-=preview
set expandtab
set fileencodings=ucs-bom,utf-8,sjis,latin1
set grepprg=grep\ -In\ $*\ /dev/null
set list listchars=tab:›\ ,trail:˽,nbsp:˲
set mouse=nv
set nohlsearch
set noshowmode
set number
set path=.,$NOTES_PATH
set sessionoptions-=buffers
set sessionoptions-=folds
set sessionoptions-=help
set sessionoptions-=tabpages
set sessionoptions-=terminal
set shada=\"0,'0,/100,:100,@0,f0,h,s4
set shiftwidth=2
set showtabline=2
set signcolumn=no
set softtabstop=2
set tabstop=4
set title
set titlestring=NeoVim
set wildignorecase

let g:loaded_netrwPlugin = 1
let g:netrw_banner = 0
let g:mapleader = '\'

" Commands
command -nargs=+ -complete=file Ggrep cex system('git grep -In --column --untracked ' .. <q-args>)
command -nargs=1 -complete=file MvTo call s:MoveFile(@%, <q-args>)
command -nargs=0 RmCur call s:RemoveFile(@%)
command -nargs=+ Indent call s:SetIndent(<f-args>)

" Shortcuts
nnoremap <silent> <C-s> :update<CR>
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
nnoremap <silent> <C-S-PageUp>   :-tabmove<CR>
nnoremap <silent> <C-S-PageDown> :+tabmove<CR>
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

" F9 Build & Run; C-F9 Build; C-F10 Run
nnoremap <silent> <F9>  :tabnew <Bar> terminal $SHELL -c 'source .nvim-actions/build && source .nvim-actions/run'<CR>
nnoremap <silent> <F33> :tabnew <Bar> terminal $SHELL .nvim-actions/build<CR>
nnoremap <silent> <F34> :tabnew <Bar> terminal $SHELL .nvim-actions/run<CR>

" Triggers
augroup autocompletion
  autocmd!
  autocmd CompleteDone * pclose
augroup end

augroup terminal
  autocmd!
  autocmd TermOpen * setlocal bufhidden=hide nonumber | startinsert
augroup end

" Script
function s:SetIndent(size, ...) abort
  " Indent with [s]pace/[t]ab, default to space
  let &expandtab = (a:0 >= 1 ? a:1 : 'space') !~? '^t'
  " Indent size
  let &softtabstop = a:size
  let &tabstop = a:size
  let &shiftwidth = a:size
endfunction

function s:MoveFile(src, dest) abort
  if &modified
    echo 'There are unsaved changes'
    return
  endif
  if a:src !=# a:dest
    call system(['mv', a:src, a:dest])
    execute 'edit ' .. a:dest
    execute 'bdelete ' .. a:src
  endif
endfunction

function s:RemoveFile(src) abort
  enew
  call system(['rm', '-f', a:src])
  execute 'bdelete! ' .. a:src
endfunction
