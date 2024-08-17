scriptencoding utf-8

" Commands
command -nargs=0 Fzf call s:fzf()

" Shortcuts
nnoremap <silent> <leader>m :Fzf<CR>

" Script
function s:fzf() abort
  if exists('s:curbuf_nr')
    echo 'Only one fzf instance can be opened at a time'
    return
  endif

  let s:curbuf_nr = 0
  if strlen(expand('%:~:.'))
    let s:curbuf_nr = bufnr()
  endif

  let s:tmpfile = tempname()
  let cmd = ['sh', '-c', 'fzf --layout=reverse > ' .. s:tmpfile]

  enew | call termopen(cmd, {'on_exit': function('s:on_exit')})
  let s:tmpbuf_nr = bufnr()
endfunction

function s:on_exit(job_id, exit_code, event_type) abort
  let selection = []
  if filereadable(s:tmpfile)
    let selection = readfile(s:tmpfile)
    call delete(s:tmpfile)
  endif

  if !empty(selection)
    execute 'edit ' .. selection[0]
  elseif s:curbuf_nr && bufexists(s:curbuf_nr)
    execute 'buffer ' .. s:curbuf_nr
  elseif !(tabpagenr('$') > 1 && tabpagewinnr(tabpagenr(), '$') == 1)
    enew
  endif

  if bufexists(s:tmpbuf_nr)
    execute 'bdelete ' .. s:tmpbuf_nr
  endif

  unlet s:curbuf_nr s:tmpfile s:tmpbuf_nr
endfunction
