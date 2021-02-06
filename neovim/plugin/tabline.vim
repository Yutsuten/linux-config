scriptencoding utf-8

" Settings
set tabline=%!UpdateTabLine()

" Shortcuts
nnoremap <leader>t :call SetTabName()<CR>

" Triggers
augroup tabmanipulation
  autocmd!
  autocmd VimEnter * call s:SessionRestored()
  autocmd TabNewEntered * call s:TabCreated()
  autocmd TabClosed * call s:TabClosed()
  autocmd TabLeave * let s:last_tab_index = tabpagenr() - 1
augroup end

" Script
let s:tab_names = ['']
let s:last_tab_index = 0
let s:ready = 0

function! s:SessionRestored()
  if exists('g:TabNames')
    let s:tab_names = split(g:TabNames, ',')
  endif
  let s:ready = 1
endfunction

function! UpdateTabLine()
  let tabline = ''
  for i in range(tabpagenr('$'))
    let tabnum = i + 1
    if tabnum == tabpagenr()
      let tabline .= '%#TabLineSel#'
    else
      let tabline .= '%#TabLine#'
    endif
    let tabline .= ' %{GetTabLabel(' . tabnum . ')} '
  endfor
  let tabline .= '%#TabLineFill#%T'
  return tabline
endfunction

function! GetTabLabel(tabnum)
  let l:tab_name = s:tab_names[a:tabnum - 1]
  if l:tab_name ==# ''
    return a:tabnum
  endif
  return a:tabnum . ' ' . l:tab_name
endfunction

function! SetTabName()
  let l:tab_index = tabpagenr() - 1
  call inputsave()
  let l:input_opts = {
        \ 'prompt': 'Tab name: ',
        \ 'default': s:tab_names[l:tab_index],
        \ 'cancelreturn': s:tab_names[l:tab_index],
        \ }
  let l:tab_name = input(l:input_opts)
  call inputrestore()
  let s:tab_names[l:tab_index] = l:tab_name
  let g:TabNames = join(s:tab_names, ',')
endfunction

function! s:TabCreated()
  if s:ready
    call insert(s:tab_names, '', tabpagenr() - 1)
    let g:TabNames = join(s:tab_names, ',')
  endif
endfunction

function! s:TabClosed()
  if s:ready
    call remove(s:tab_names, s:last_tab_index)
    let g:TabNames = join(s:tab_names, ',')
  endif
endfunction
