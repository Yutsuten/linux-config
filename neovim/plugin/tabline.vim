scriptencoding utf-8

set tabline=%!UpdateTabLine()

function UpdateTabLine()
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

function GetTabLabel(tabnum)
  return a:tabnum
endfunction
