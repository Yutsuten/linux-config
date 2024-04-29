scriptencoding utf-8

" Settings
set tabline=%!UpdateTabLine()

" Script
function UpdateTabLine()
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
  let tabline .= '%#TabLineFill#%T %= %{fnamemodify(getcwd(), ":~")} '
  return tabline
endfunction
