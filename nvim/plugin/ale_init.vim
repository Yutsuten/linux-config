set omnifunc=ale#completion#OmniFunc

let g:ale_python_pyls_config = {
\  'pyls': { 'configurationSources': ['flake8'] }
\}

let g:ale_linters = {
\   'python': ['flake8', 'pylint', 'pyls']
\}
