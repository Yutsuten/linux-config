scriptencoding utf-8

" Commands
command -nargs=? -complete=dir Nnn call s:Nnn(<f-args>)

" Shortcuts
nnoremap <silent> <leader>n :Nnn<CR>
nnoremap <silent> <leader>N :Nnn %:p:h<CR>
nnoremap <silent> <C-n> :tabnew +Nnn<CR>

" Script
function s:Nnn(...) abort
  if exists('s:curbuf_nr')
    echo 'Only one nnn instance can be opened at a time'
    return
  endif

  let s:curbuf_nr = 0
  if strlen(expand('%'))
    let s:curbuf_nr = bufnr()
  endif

  let s:tmpfile = tempname()
  let cmd = ['nnn', '-p', s:tmpfile]
  if a:0
    call add(cmd, fnamemodify(a:1, ':p'))
  endif

  enew | call termopen(cmd, {'on_exit': function('s:OnExit')})
  let s:tmpbuf_nr = bufnr()
endfunction

function s:OnExit(job_id, exit_code, event_type) abort
  let selection = []
  if filereadable(s:tmpfile)
    let selection = readfile(s:tmpfile)
    call delete(s:tmpfile)
  endif

  if !empty(selection)
    execute 'edit ' .. fnamemodify(selection[0], ':.')
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
