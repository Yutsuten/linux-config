scriptencoding utf-8

" Commands
command -nargs=0 ToggleFileInfo call s:ToggleFileInfo()

" Triggers
augroup statusline
  autocmd!
  autocmd VimEnter,WinEnter,BufEnter,SessionLoadPost,FileChangedShellPost,TermLeave * call s:UpdateStatusLine()
  autocmd VimEnter * highlight link StatusLineMode StatusLineBlue
  autocmd VimEnter * highlight link StatusLineLinter StatusLineLinterGreen
augroup end

" Script
let s:show_file_info = 0

function s:ToggleFileInfo() abort
  let s:show_file_info = !s:show_file_info
  call s:UpdateStatusLine()
endfunction

function s:UpdateStatusLine() abort
  if win_gettype() ==# 'popup'
    return
  endif

  let l:statusline  = '%0* %t %m %h'
  let l:statusline .= '%='

  let l:active_statusline  = '%#StatusLineMode# %{GetCurrentMode()} '
  let l:active_statusline .= statusline
  if s:show_file_info
    let l:active_statusline .= '%y [%{!empty(&fileencoding)?&fileencoding:&encoding}] [%{&fileformat}] '
  else
    let l:active_statusline .= '%{((!empty(&fileencoding) && &fileencoding !=# "utf-8") || &fileformat !=# "unix")?"⚠  ":""}'
  endif
  let l:active_statusline .= '[ind:%{&shiftwidth}] '
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

function GetCurrentMode() abort
  let l:current_mode = mode()
  if l:current_mode ==# 'n'
    let l:current_mode = 'NORMAL'
    highlight link StatusLineMode StatusLineBlue
  elseif l:current_mode ==# 'i'
    let l:current_mode = 'INSERT'
    highlight link StatusLineMode StatusLineGreen
  elseif l:current_mode ==# 'v'
    let l:current_mode = 'VISUAL'
    highlight link StatusLineMode StatusLineMagenta
  elseif l:current_mode ==# 'V'
    let l:current_mode = 'V-LINE'
    highlight link StatusLineMode StatusLineMagenta
  elseif l:current_mode ==# "\<C-v>"
    let l:current_mode = 'V-BLOCK'
    highlight link StatusLineMode StatusLineMagenta
  elseif l:current_mode ==# 'R'
    let l:current_mode = 'REPLACE'
    highlight link StatusLineMode StatusLineRed
  elseif l:current_mode ==# 'c'
    let l:current_mode = 'COMMAND'
    highlight link StatusLineMode StatusLineYellow
  elseif l:current_mode ==# 't'
    let l:current_mode = 'TERMINAL'
    highlight link StatusLineMode StatusLineYellow
  elseif l:current_mode ==# 's'
    let l:current_mode = 'SELECT'
    highlight link StatusLineMode StatusLineRed
  elseif l:current_mode ==# 'S'
    let l:current_mode = 'S-LINE'
    highlight link StatusLineMode StatusLineRed
  elseif l:current_mode ==# "\<C-s>"
    let l:current_mode = 'S-BLOCK'
    highlight link StatusLineMode StatusLineRed
  endif
  return l:current_mode
endfunction

function LinterStatus() abort
  let l:error_count = luaeval('#vim.diagnostic.get(0, {severity=vim.diagnostic.severity.ERROR})')
  let l:warning_count = luaeval('#vim.diagnostic.get(0, {severity=vim.diagnostic.severity.WARN})')
  let l:info_count = luaeval('#vim.diagnostic.get(0, {severity=vim.diagnostic.severity.INFO})')
  let l:hint_count = luaeval('#vim.diagnostic.get(0, {severity=vim.diagnostic.severity.HINT})')

  if l:error_count > 0
    highlight link StatusLineLinter StatusLineRed
    return printf(' ✗%d ‼%d ', l:error_count, l:warning_count)
  elseif l:warning_count > 0
    highlight link StatusLineLinter StatusLineYellow
    return printf(' ‼%d ', l:warning_count)
  elseif l:info_count + l:hint_count > 0
    highlight link StatusLineLinter StatusLineBlue
    return printf(' 𝒾%d ', l:info_count + l:hint_count)
  endif
  highlight link StatusLineLinter StatusLineGreen
  return ' ✓ '
endfunction
