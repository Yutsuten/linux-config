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
  call termopen(cmd, {'on_exit': funcref('s:callback')})
endfunction

function s:callback(...) abort
  let selection = []
  if filereadable(s:nnn_tmpfile)
    let selection = readfile(s:nnn_tmpfile)
  endif

  if !empty(selection)
    execute 'edit ' .. selection[0] .. ' | bdelete #'
  elseif strlen(s:curfile)
    execute 'edit ' .. s:curfile .. ' | bdelete #'
  else
    execute 'enew | bdelete #'
  endif
  unlet s:curfile
endfunction
