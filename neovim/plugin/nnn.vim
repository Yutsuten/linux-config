scriptencoding utf-8

let g:nnn#set_default_mappings = 0
nnoremap <leader>N :NnnPicker<CR>
nnoremap <leader>n :NnnPicker %:p:h<CR>

let g:nnn#layout = { 'window': { 'width': 0.9, 'height': 0.8, 'highlight': 'Comment', 'border': 'rounded' } }
