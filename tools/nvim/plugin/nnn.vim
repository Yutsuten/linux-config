scriptencoding utf-8

" Commands
command -nargs=? -complete=dir Nnn call s:Nnn(<f-args>)

" Shortcuts
nnoremap <silent> <leader>n :Nnn<CR>
nnoremap <silent> <leader>N :Nnn %:p:h<CR>

" Script
function s:Nnn(...) abort
  if exists('s:curfile')
    echo 'Only one nnn instance can be opened at a time'
    return
  endif
  let s:curfile = expand('%:~:.')
  let s:nnn_tmpfile = tempname()
  let cmd = ['nnn', '-p', s:nnn_tmpfile]
  if a:0
    call add(cmd, fnamemodify(a:1, ':p'))
  endif
  enew
  call termopen(cmd, {'on_exit': function('s:callback')})
  let s:nnn_buffer = bufnr()
endfunction

function s:callback(job_id, exit_code, event_type) abort
  let selection = []
  if filereadable(s:nnn_tmpfile)
    let selection = readfile(s:nnn_tmpfile)
    call delete(s:nnn_tmpfile)
  endif

  if !empty(selection)
    execute 'edit ' .. selection[0]
  elseif strlen(s:curfile)
    execute 'edit ' .. s:curfile
  else
    enew
  endif
  if bufexists(s:nnn_buffer)
    execute 'bdelete ' .. s:nnn_buffer
  endif

  unlet s:curfile
  unlet s:nnn_tmpfile
  unlet s:nnn_buffer
endfunction
