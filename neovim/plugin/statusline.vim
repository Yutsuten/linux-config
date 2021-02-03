scriptencoding utf-8

" Triggers
augroup statusline
  autocmd!
  autocmd VimEnter,WinEnter,BufEnter,BufDelete,SessionLoadPost,FileChangedShellPost * call s:UpdateStatusLine()
  autocmd VimEnter * highlight StatusLine ctermbg=0 ctermfg=14 cterm=NONE gui=NONE
  autocmd VimEnter * highlight StatusLineNC ctermbg=0 ctermfg=10 cterm=NONE gui=NONE
  autocmd VimEnter * highlight StatusLineSub ctermbg=11 ctermfg=0 cterm=NONE gui=NONE
  autocmd VimEnter * highlight StatusLineMode ctermbg=4 ctermfg=0 cterm=NONE gui=NONE
  autocmd VimEnter * highlight StatusLineLinter ctermbg=2 ctermfg=0 cterm=NONE gui=NONE
augroup end

" Script
function! s:UpdateStatusLine()
  let l:statusline  = "%0* %<%{expand('%:t')} %m %h"
  let l:statusline .= '%='
  let l:statusline .= '%y [%{!empty(&fileencoding)?&fileencoding:&encoding}] [%{&fileformat}] '

  let l:active_statusline  = '%#StatusLineMode# %{GetCurrentMode()} '
  let l:active_statusline .= statusline
  let l:active_statusline .= '%#StatusLineSub# %2l,%-2c '
  let l:active_statusline .= '%#StatusLineLinter#%{LinterStatus()}'

  let l:cur_win_num = winnr()
  for l:win_num in range(1, winnr('$'))
    if l:cur_win_num == l:win_num
      call setwinvar(l:win_num, '&statusline', l:active_statusline)
    else
      call setwinvar(l:win_num, '&statusline', l:statusline)
    endif
  endfor
endfunction

function! GetCurrentMode()
  let l:current_mode = mode()
  if l:current_mode ==# 'n'
    let l:current_mode = 'NORMAL'
    highlight StatusLineMode ctermbg=4
  elseif l:current_mode ==# 'i'
    let l:current_mode = 'INSERT'
    highlight StatusLineMode ctermbg=2
  elseif l:current_mode ==# 'v'
    let l:current_mode = 'VISUAL'
    highlight StatusLineMode ctermbg=5
  elseif l:current_mode ==# 'V'
    let l:current_mode = 'V-LINE'
    highlight StatusLineMode ctermbg=5
  elseif l:current_mode ==# "\<C-v>"
    let l:current_mode = 'V-BLOCK'
    highlight StatusLineMode ctermbg=5
  elseif l:current_mode ==# 'R'
    let l:current_mode = 'REPLACE'
    highlight StatusLineMode ctermbg=9
  elseif l:current_mode ==# 'c'
    let l:current_mode = 'COMMAND'
    highlight StatusLineMode ctermbg=3
  elseif l:current_mode ==# 't'
    let l:current_mode = 'TERMINAL'
    highlight StatusLineMode ctermbg=3
  elseif l:current_mode ==# 's'
    let l:current_mode = 'SELECT'
    highlight StatusLineMode ctermbg=9
  elseif l:current_mode ==# 'S'
    let l:current_mode = 'S-LINE'
    highlight StatusLineMode ctermbg=9
  elseif l:current_mode ==# "\<C-s>"
    let l:current_mode = 'S-BLOCK'
    highlight StatusLineMode ctermbg=9
  endif
  return l:current_mode
endfunction

function! LinterStatus()
  if !exists('*ale#linter#Get') || len(ale#linter#Get(&filetype)) == 0
    return ''
  endif

  let l:counts = ale#statusline#Count(bufnr())
  let l:error_count = l:counts.error + l:counts.style_error
  let l:warning_count = l:counts.warning + l:counts.style_warning

  call SetSignColumn(l:counts.total > 0)

  if l:error_count > 0
    highlight StatusLineLinter ctermbg=1
    return printf(' ✗%d ‼%d ', l:error_count, l:warning_count)
  elseif l:warning_count > 0
    highlight StatusLineLinter ctermbg=3
    return printf(' ‼%d ', l:warning_count)
  elseif l:counts.info > 0
    highlight StatusLineLinter ctermbg=13
    return printf(' 𝒾%d ', l:counts.info)
  endif
  highlight StatusLineLinter ctermbg=2
  return ' ✓ '
endfunction

function! SetSignColumn(visible)
  if a:visible
    let &signcolumn='auto:1'
  else
    let &signcolumn='no'
  endif
endfunction
