scriptencoding utf-8

" Settings
set tabline=%!UpdateTabLine()

" Commands
command! -nargs=? TabName call s:SetCurrentTabName(<f-args>)

" Triggers
augroup tabmanipulation
  autocmd!
  autocmd TabNewEntered * call insert(s:tab_names, '', tabpagenr() - 1)
  autocmd TabClosed * call remove(s:tab_names, s:last_tab_index)
  autocmd TabLeave * let s:last_tab_index = tabpagenr() - 1
augroup end

" Script
let s:tab_names = ['']
let s:last_tab_index = 0

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

function! s:SetCurrentTabName(...)
  let l:tab_index = tabpagenr() - 1
  if !a:0
    let s:tab_names[l:tab_index] = ''
  else
    let s:tab_names[l:tab_index] = a:1
  endif
endfunction
