scriptencoding utf-8

set expandtab
set list listchars=tab:›\ ,trail:˽,nbsp:˲
set nohlsearch
set noshowmode
set number
set shiftwidth=4
set softtabstop=4
set tabstop=4
set updatetime=300

let mapleader = '\'

function! g:OutputToPreviewWindow(content)
  let path = '/tmp/nvim-preview'
  call writefile(split(a:content, '\n'), path)
  execute 'pedit' fnameescape(path)
endfunction

function! s:SetIndent(val)
  let &shiftwidth = a:val
  let &softtabstop = a:val
endfunction

function! s:ToggleIndent()
  if &shiftwidth != 4
    call s:SetIndent(4)
  else
    call s:SetIndent(2)
  endif
endfunction

command! -nargs=1 Indent call s:SetIndent(<f-args>)
command! -nargs=0 ToggleIndent call s:ToggleIndent()
command! -nargs=* Nmake call jobstart(['nmake', <f-args>])

nnoremap <leader>r :call jobstart(['nmake'])<CR>
nnoremap <leader>i :ToggleIndent<CR>
nnoremap <leader>% :let @+ = @%<CR>

augroup terminal
  autocmd!
  autocmd TermOpen * setlocal bufhidden=hide nonumber
augroup end

augroup statusline
  autocmd!
  autocmd VimEnter,WinEnter,BufEnter,BufDelete,SessionLoadPost,FileChangedShellPost * call UpdateStatusLine()
  autocmd VimEnter * highlight StatusLine ctermbg=0 ctermfg=14 cterm=NONE gui=NONE
  autocmd VimEnter * highlight StatusLineNC ctermbg=0 ctermfg=10 cterm=NONE gui=NONE
  autocmd VimEnter * highlight StatusLineSub ctermbg=11 ctermfg=0 cterm=NONE gui=NONE
  autocmd VimEnter * highlight StatusLineMode ctermbg=4 ctermfg=0 cterm=NONE gui=NONE
augroup end

function! UpdateStatusLine()
  let statusline  = "%0* %y %<%{expand('%:t')} %m %h"     "Left aligned
  let statusline .= '%='                                  "Separation
  let statusline .= '%{FileInfo()} '                      "Right aligned

  let active_statusline  = '%#StatusLineMode# %{CurrentMode()} '
  let active_statusline .= statusline
  let active_statusline .= '%#StatusLineSub# %2l:%-2c '

  let cur_win_num = winnr()
  for win_num in range(1, winnr('$'))
    if cur_win_num == win_num
      call setwinvar(win_num, '&statusline', active_statusline)
    else
      call setwinvar(win_num, '&statusline', statusline)
    endif
  endfor
endfunction

function! CurrentMode()
  let current_mode = mode()
  if current_mode ==# 'n'
    let current_mode = 'NORMAL'
    highlight StatusLineMode ctermbg=4
  elseif current_mode ==# 'i'
    let current_mode = 'INSERT'
    highlight StatusLineMode ctermbg=2
  elseif current_mode ==# 'v'
    let current_mode = 'VISUAL'
    highlight StatusLineMode ctermbg=5
  elseif current_mode ==# 'V'
    let current_mode = 'V-LINE'
    highlight StatusLineMode ctermbg=5
  elseif current_mode ==# "\<C-v>"
    let current_mode = 'V-BLOCK'
    highlight StatusLineMode ctermbg=5
  elseif current_mode ==# 'R'
    let current_mode = 'REPLACE'
    highlight StatusLineMode ctermbg=9
  elseif current_mode ==# 'c'
    let current_mode = 'COMMAND'
    highlight StatusLineMode ctermbg=3
  elseif current_mode ==# 't'
    let current_mode = 'TERMINAL'
    highlight StatusLineMode ctermbg=3
  elseif current_mode ==# 's'
    let current_mode = 'SELECT'
    highlight StatusLineMode ctermbg=9
  elseif current_mode ==# 'S'
    let current_mode = 'S-LINE'
    highlight StatusLineMode ctermbg=9
  elseif current_mode ==# "\<C-s>"
    let current_mode = 'S-BLOCK'
    highlight StatusLineMode ctermbg=9
  endif
  return current_mode
endfunction

function! FileInfo()
  return &fileencoding?&fileencoding:&encoding . ' [' . &fileformat . ']'
endfunction
