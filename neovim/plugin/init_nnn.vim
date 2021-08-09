scriptencoding utf-8

let g:nnn#set_default_mappings = 0
let g:nnn#layout = 'enew'
let g:nnn#replace_netrw = 1
let g:nnn#statusline = 0

function NnnPick(...)
  if a:0 > 0
    call nnn#pick(a:1)
  else
    call nnn#pick(expand('%:p:h'))
  endif
endfunction

command -nargs=? -complete=file Explore call NnnPick(<f-args>)
