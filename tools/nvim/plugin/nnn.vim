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
  let s:tmpfile = tempname()
  let cmd = ['nnn', '-p', s:tmpfile]
  if a:0
    call add(cmd, fnamemodify(a:1, ':p'))
  endif
  enew
  call termopen(cmd, {'on_exit': function('s:callback')})
  let s:buffer_nr = bufnr()
endfunction

function s:callback(job_id, exit_code, event_type) abort
  let selection = []
  if filereadable(s:tmpfile)
    let selection = readfile(s:tmpfile)
    call delete(s:tmpfile)
  endif

  if !empty(selection)
    execute 'edit ' .. selection[0]
  elseif strlen(s:curfile)
    execute 'edit ' .. s:curfile
  else
    enew
  endif
  if bufexists(s:buffer_nr)
    execute 'bdelete ' .. s:buffer_nr
  endif

  unlet s:curfile
  unlet s:tmpfile
  unlet s:buffer_nr
endfunction
