scriptencoding utf-8

set expandtab
set list listchars=tab:›\ ,trail:˽,nbsp:˲
set nohlsearch
set noshowmode
set number
set shiftwidth=4
set softtabstop=4
set tabstop=4
set fileencodings=ucs-bom,utf-8,sjis,latin1
set signcolumn=auto:1

let g:netrw_banner=0
let mapleader = '\'

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

" Nmake-start
let s:make_running = 0
let s:make_args = []
let s:make_stderr = ''

function! s:NmakeFinished(job_id, data, event) dict
  let l:make_cmd = 'make'
  for arg in s:make_args
    let l:make_cmd .= ' ' . arg
  endfor

  let l:notify_cmd = ['notify-send', '-a', 'Neovim']
  if a:data == 0
    let l:notify_cmd += ['-i', '/usr/share/icons/breeze-dark/status/64/dialog-positive.svg']
    let l:notify_cmd += ['Run: ' . l:make_cmd, 'Command finished successfully!']
  else
    let l:notify_cmd += ['-i', '/usr/share/icons/breeze-dark/status/64/dialog-error.svg']
    let l:notify_cmd += ['Run: ' . l:make_cmd, s:make_stderr]
  endif
  if jobstart(l:notify_cmd) == -1
    echo a:data == 0 ? 'Command finished successfully!' : s:make_stderr
  endif
  let s:make_running = 0
endfunction

function! s:NmakeStderr(job_id, data, event) dict
  let s:make_stderr .= join(a:data, '')
endfunction

function! s:Nmake(...)
  let s:make_args = a:000
  let s:make_stderr = ''
  if !s:make_running
    let s:make_running = 1
    call jobstart(['make'] + a:000, {'on_exit': function('s:NmakeFinished'), 'on_stderr': function('s:NmakeStderr')})
  endif
endfunction
" Nmake-end

command! -nargs=1 Indent call s:SetIndent(<f-args>)
command! -nargs=0 ToggleIndent call s:ToggleIndent()
command! -nargs=? Nmake call s:Nmake(<f-args>)

nnoremap <leader>r :Nmake<CR>
nnoremap <leader>i :ToggleIndent<CR>
nnoremap <leader>% :let @+ = @%<CR>

augroup autocompletion
  autocmd!
  autocmd CompleteDone * pclose
augroup end

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
  autocmd VimEnter * highlight StatusLineLinter ctermbg=2 ctermfg=0 cterm=NONE gui=NONE
augroup end

function! UpdateStatusLine()
  let l:statusline  = "%0* %<%{expand('%:t')} %m %h"
  let l:statusline .= '%='
  let l:statusline .= '%y [%{!empty(&fileencoding)?&fileencoding:&encoding}] [%{&fileformat}] '

  let l:active_statusline  = '%#StatusLineMode# %{CurrentMode()} '
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

function! CurrentMode()
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
