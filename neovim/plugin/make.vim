scriptencoding utf-8

" Commands
command -nargs=? Make call s:Make(<f-args>)
command -nargs=0 MakeLog call s:MakeLog()

" Script
let s:running = 0
let s:command = 'make'
let s:stderr = []
let s:log_file = $HOME . '/.cache/nvim/make.log'

function s:MakeLog()
  execute 'top split | view ' . s:log_file
endfunction

function s:Make(...)
  if !s:running
    let s:running = 1
    let s:command = ['make'] + a:000
    call jobstart(s:command, {'on_exit': function('s:Finish'), 'on_stdout': function('s:OnStdout'), 'on_stderr': function('s:OnStderr'), 'stdout_buffered': 1, 'stderr_buffered': 1})
    call writefile(['>> Execute "' . join(s:command, ' ') . '" at ' . strftime('%Y/%m/%d %H:%M:%S') . ' <<'], s:log_file)
  endif
endfunction

function s:OnStdout(job_id, data, event) dict
  call writefile(a:data, s:log_file, 'a')
endfunction

function s:OnStderr(job_id, data, event) dict
  call writefile(a:data, s:log_file, 'a')
  let s:stderr += a:data
endfunction

function s:Finish(job_id, data, event) dict
  let l:notify_cmd = ['notify-send', '-a', 'Neovim']
  if a:data == 0
    let l:notify_cmd += ['--icon', 'dialog-info']
    let l:notify_cmd += ['Run: ' . join(s:command, ' '), 'Command finished successfully!']
  else
    let l:notify_cmd += ['--icon', 'dialog-error']
    let l:notify_cmd += ['Run: ' . join(s:command, ' '), join(s:stderr, '')]
  endif
  if jobstart(l:notify_cmd) == -1
    echo a:data == 0 ? 'Command finished successfully!' : join(s:stderr, '')
  endif
  let s:running = 0
  let s:stderr = []
endfunction
