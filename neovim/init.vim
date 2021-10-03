scriptencoding utf-8

" Settings
set expandtab
set list listchars=tab:›\ ,trail:˽,nbsp:˲
set nohlsearch
set noshowmode
set number
set shiftwidth=2
set softtabstop=2
set tabstop=4
set fileencodings=ucs-bom,utf-8,sjis,latin1
set sessionoptions-=buffers
set sessionoptions+=globals

let g:netrw_banner=0
let g:mapleader = '\'

" Commands
command -nargs=1 Indent call s:SetIndent(<f-args>)
command -nargs=0 ToggleIndent call s:ToggleIndent()

" Shortcuts
nnoremap <leader>r :Make<CR>
nnoremap <leader>i :ToggleIndent<CR>
nnoremap <leader>% :let @+ = @%<CR>

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
function s:SetIndent(val)
  let &shiftwidth = a:val
  let &softtabstop = a:val
endfunction

function s:ToggleIndent()
  if &shiftwidth != 4
    call s:SetIndent(4)
  else
    call s:SetIndent(2)
  endif
endfunction
