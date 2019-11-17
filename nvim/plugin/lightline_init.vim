let g:lightline = {
\   'colorscheme': 'solarized',
\   'active': {
\     'left': [
\       ['mode', 'paste'],
\       ['gitbranch'],
\       ['readonly', 'filename']
\     ],
\     'right': [
\       ['linterstatus'],
\       ['lineinfo'],
\       ['fileinfo', 'filetype'],
\     ]
\   },
\   'component_function': {
\     'gitbranch': 'FugitiveHead',
\     'fileinfo': 'LightlineFileinfo',
\     'filename': 'LightlineFilename',
\     'linterstatus': 'LinterStatus'
\   }
\ }

function LightlineFileinfo()
  if &filetype ==# 'netrw' || &fileencoding ==# '' || (&fileencoding ==# 'utf-8' && &fileformat ==# 'unix')
    return ''
  endif
  return &fileencoding . '[' . &fileformat . ']'
endfunction

function LightlineFilename()
  let filename = expand('%:t') !=# '' ? fnamemodify(@%, ':~:.') : '[No Name]'
  let modified = &modified ? '+' : ''
  return filename[-40:] . modified
endfunction

function LinterStatus() abort
  if &filetype ==# 'netrw'
    return ''
  endif
  let l:counts = ale#statusline#Count(bufnr(''))
  let l:all_errors = l:counts.error + l:counts.style_error
  let l:all_non_errors = l:counts.total - l:all_errors
  return l:counts.total == 0 ? 'OK' : printf('%dW %dE', all_non_errors, all_errors)
endfunction
