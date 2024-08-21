scriptencoding utf-8

" Commands
command -nargs=0 Fzf call s:fzf_file()

" Shortcuts
nnoremap <silent> <leader>m :Fzf<CR>

" Script
function s:fzf_file() abort
  let blacklist = [
  \   '-name .git',
  \   '-name node_modules',
  \ ]
  call s:fzf('find . -type d \( ' .. join(blacklist, ' -o ') .. ' \) -prune -o -type f -printf "%P\n"', function('s:fzf_file_exit'))
endfunction

function s:fzf_file_exit(job_id, exit_code, event_type) abort
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

function s:fzf(input_cmd, on_exit) abort
  if exists('s:curbuf_nr')
    echo 'Only one fzf instance can be opened at a time'
    return
  endif

  let s:curbuf_nr = 0
  if strlen(expand('%:~:.'))
    let s:curbuf_nr = bufnr()
  endif

  let s:tmpfile = tempname()
  let cmd = a:input_cmd .. ' | fzf --layout=reverse > ' .. s:tmpfile

  enew | call termopen(['sh', '-c', cmd], {'on_exit': a:on_exit})
  let s:tmpbuf_nr = bufnr()
endfunction
