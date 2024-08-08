scriptencoding utf-8

" Commands
command -nargs=0 Nnn call s:Nnn()

" Shortcuts
nnoremap <silent> <leader>n :Nnn<CR>

" Script
function s:Nnn() abort
  if exists('s:curfile')
    echo 'Only one nnn instance can be opened at a time'
    return
  endif
  let s:curfile = expand('%:~:.')
  let s:nnn_tmpfile = tempname()
  let jobopts = {'on_exit': funcref('s:callback')}
  enew
  call termopen(['nnn', '-p', s:nnn_tmpfile], jobopts)
endfunction

function s:callback(...) abort
  let selection = []
  if filereadable(s:nnn_tmpfile)
    let selection = readfile(s:nnn_tmpfile)
  endif

  if empty(selection)
    execute 'edit ' .. s:curfile .. ' | bdelete #'
  else
    execute 'edit ' .. selection[0] .. ' | bdelete #'
  endif
  unlet s:curfile
endfunction
