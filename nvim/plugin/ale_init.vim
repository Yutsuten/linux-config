set omnifunc=ale#completion#OmniFunc

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
