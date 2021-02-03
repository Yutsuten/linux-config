scriptencoding utf-8

" Commands
command! -nargs=? Nmake call s:Nmake(<f-args>)

" Script
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
    let l:notify_cmd += ['-i', '~/Pictures/Icons/success.svg']
    let l:notify_cmd += ['Run: ' . l:make_cmd, 'Command finished successfully!']
  else
    let l:notify_cmd += ['-i', '~/Pictures/Icons/error.svg']
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
