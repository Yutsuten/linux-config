scriptencoding utf-8

let g:nnn#set_default_mappings = 0
let g:nnn#layout = 'enew'
let g:nnn#replace_netrw = 1
let g:nnn#statusline = 0

command! -nargs=? -complete=file NnnPicker call nnn#pick(expand('%:p:h'))
command! -nargs=? -complete=file Np call nnn#pick(expand('%:p:h'))

nnoremap <leader>n :NnnPicker<CR>
