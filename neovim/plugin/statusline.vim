scriptencoding utf-8

" Commands
command -nargs=0 ToggleFileInfo call s:ToggleFileInfo()

" Triggers
augroup statusline
  autocmd!
  autocmd VimEnter,WinEnter,BufEnter,SessionLoadPost,FileChangedShellPost * call s:UpdateStatusLine()
  autocmd VimEnter * highlight StatusLine ctermbg=0 ctermfg=14 cterm=NONE gui=NONE
  autocmd VimEnter * highlight StatusLineNC ctermbg=0 ctermfg=10 cterm=NONE gui=NONE
  autocmd VimEnter * highlight StatusLineSub ctermbg=11 ctermfg=0 cterm=NONE gui=NONE
  autocmd VimEnter * highlight StatusLineMode ctermbg=4 ctermfg=0 cterm=NONE gui=NONE
  autocmd VimEnter * highlight StatusLineLinter ctermbg=2 ctermfg=0 cterm=NONE gui=NONE
augroup end

" Script
let s:show_file_info = 0

function s:ToggleFileInfo()
  let s:show_file_info = !s:show_file_info
  call s:UpdateStatusLine()
endfunction

function s:UpdateStatusLine()
  if win_gettype() == 'popup'
    return
  endif

  let l:statusline  = "%0* %<%{expand('%:t')} %m %h"
  let l:statusline .= '%='
  if s:show_file_info
    let l:statusline .= '[ind:%{&shiftwidth}] %y [%{!empty(&fileencoding)?&fileencoding:&encoding}] [%{&fileformat}] '
  else
    if (!empty(&fileencoding) && &fileencoding !=# 'utf-8') || &fileformat !=# 'unix'
      let l:statusline .= '⚠  '
    endif
  endif

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

function GetCurrentMode()
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

function LinterStatus()
  if !luaeval('not vim.tbl_isempty(vim.lsp.buf_get_clients(0))')
    return ''
  endif
  let l:error_count = luaeval('vim.lsp.diagnostic.get_count(0, [[Error]])')
  let l:warning_count = luaeval('vim.lsp.diagnostic.get_count(0, [[Warning]])')
  let l:info_count = luaeval('vim.lsp.diagnostic.get_count(0, [[Information]])')
  let l:hint_count = luaeval('vim.lsp.diagnostic.get_count(0, [[Hint]])')

  if l:error_count > 0
    highlight StatusLineLinter ctermbg=1
    return printf(' ✗%d ‼%d ', l:error_count, l:warning_count)
  elseif l:warning_count > 0
    highlight StatusLineLinter ctermbg=3
    return printf(' ‼%d ', l:warning_count)
  elseif l:info_count + l:hint_count > 0
    highlight StatusLineLinter ctermbg=13
    return printf(' 𝒾%d ', l:info_count + l:hint_count)
  endif
  highlight StatusLineLinter ctermbg=2
  return ' ✓ '
endfunction
