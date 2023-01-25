setlocal shiftwidth=4
setlocal softtabstop=4

function! s:Pydoc()
  let iskeyword = &iskeyword
  setlocal iskeyword +=.
  let selected_word = expand('<cword>')
  let &iskeyword = iskeyword
  call g:OutputToPreviewWindow(system('pydoc ' . selected_word))
endfunction

command! -nargs=0 Pydoc call s:Pydoc()
