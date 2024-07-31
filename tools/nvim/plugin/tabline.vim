scriptencoding utf-8

" Settings
set tabline=%!UpdateTabLine()

" Script
function UpdateTabLine() abort
  let tabline = ''
  for i in range(tabpagenr('$'))
    let tabnum = i + 1
    if tabnum == tabpagenr()
      let tabline .= '%#TabLineSel#'
    else
      let tabline .= '%#TabLine#'
    endif
    let tabline .= ' [' . tabnum . '] '
  endfor
  let tabline .= '%#TabLineFill#%T %= %{GetDirInfo()} '
  return tabline
endfunction

function GetDirInfo() abort
  let l:curdir = fnamemodify(getcwd(), ':~')
  if exists('b:gitsigns_head')
    return l:curdir .. ' @ ' .. b:gitsigns_head
  else
    return l:curdir
  endif
endfunction
