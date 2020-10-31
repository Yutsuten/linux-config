scriptencoding utf-8

set omnifunc=ale#completion#OmniFunc

augroup alehighlight
  autocmd!
  autocmd VimEnter * highlight ALEErrorSign ctermfg=1 ctermbg=0
  autocmd VimEnter * highlight ALEWarningSign ctermfg=3 ctermbg=0
  autocmd VimEnter * highlight ALEInfoSign ctermfg=13 ctermbg=0
augroup end

let g:ale_sign_error = ' ✗'
let g:ale_sign_warning = ' ‼'
let g:ale_sign_info = ' 𝒾'

let g:ale_python_pyls_config = {
\  'pyls': { 'configurationSources': ['flake8'] }
\}

nnoremap <leader>n :ALENext<CR>
nnoremap <leader>p :ALEPrevious<CR>

nnoremap <leader>d :ALEGoToDefinition<CR>
nnoremap <leader>f :ALEFindReferences -relative<CR>
nnoremap <leader>h :ALEHover<CR>
nnoremap <leader>s :ALESymbolSearch -relative 
nnoremap <leader>e :ALEFix<CR>
