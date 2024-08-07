" ==============================================================================
"   Name:        One Half Dark
"   Author:      Son A. Pham <sp@sonpham.me>
"   Url:         https://github.com/sonph/onehalf
"   License:     The MIT License (MIT)
"
"   A dark vim color scheme based on Atom's One. See github.com/sonph/onehalf
"   for installation instructions, a light color scheme, versions for other
"   editors/terminals, and a matching theme for vim-airline.
"   This is a customized version of the color scheme.
" ==============================================================================

set background=dark
highlight clear
syntax reset

let g:colors_name='onehalfdark'
let colors_name='onehalfdark'


let s:black       = { 'gui': '#282C34', 'cterm': '0'  }
let s:red         = { 'gui': '#E06C75', 'cterm': '1'  }
let s:green       = { 'gui': '#98C379', 'cterm': '2'  }
let s:yellow      = { 'gui': '#E5C07B', 'cterm': '3'  }
let s:blue        = { 'gui': '#61AFEF', 'cterm': '4'  }
let s:magenta     = { 'gui': '#C678DD', 'cterm': '5'  }
let s:cyan        = { 'gui': '#56B6C2', 'cterm': '6'  }
let s:white       = { 'gui': '#919BAA', 'cterm': '7'  }
let s:brblack     = { 'gui': '#474E5D', 'cterm': '8'  }
let s:brred       = { 'gui': '#E06C75', 'cterm': '9'  }
let s:brgreen     = { 'gui': '#98C379', 'cterm': '10' }
let s:bryellow    = { 'gui': '#E5C07B', 'cterm': '11' }
let s:brblue      = { 'gui': '#61AFEF', 'cterm': '12' }
let s:brmagenta   = { 'gui': '#C678DD', 'cterm': '13' }
let s:brcyan      = { 'gui': '#56B6C2', 'cterm': '14' }
let s:brwhite     = { 'gui': '#DCDFE4', 'cterm': '15' }

let s:fg          = s:brwhite
let s:bg          = s:black

let s:comment_fg  = s:white
let s:gutter_bg   = s:black
let s:gutter_fg   = s:white
let s:non_text    = { 'gui': '#373C45', 'cterm': '239' }
let s:selection   = s:brblack
let s:warning_fg  = { 'gui': '#AF8700', 'cterm': '136' }
let s:cur_line_bg = { 'gui': '#2D333E', 'cterm': 'NONE' }


function s:h(group, fg, bg, attr) abort
  if type(a:fg) == type({})
    execute 'highlight ' .. a:group .. ' guifg=' .. a:fg.gui .. ' ctermfg=' .. a:fg.cterm
  else
    execute 'highlight ' .. a:group .. ' guifg=NONE cterm=NONE'
  endif
  if type(a:bg) == type({})
    execute 'highlight ' .. a:group .. ' guibg=' .. a:bg.gui .. ' ctermbg=' .. a:bg.cterm
  else
    execute 'highlight ' .. a:group .. ' guibg=NONE ctermbg=NONE'
  endif
  if a:attr !=# ''
    execute 'highlight ' .. a:group .. ' gui=' .. a:attr .. ' cterm=' .. a:attr
  else
    execute 'highlight ' .. a:group .. ' gui=NONE cterm=NONE'
  endif
endfun


" User interface colors {
call s:h('Normal', s:fg, '', '')

call s:h('Cursor', s:bg, s:blue, '')
call s:h('CursorColumn', '', '', '')
call s:h('CursorLine', '', s:cur_line_bg, '')
call s:h('CursorLineNr', s:fg, s:gutter_bg, '')

call s:h('DiffAdd', s:green, '', '')
call s:h('DiffChange', s:yellow, '', '')
call s:h('DiffDelete', s:red, '', '')
call s:h('DiffText', s:blue, '', '')

call s:h('IncSearch', s:bg, s:yellow, '')
call s:h('Search', s:bg, s:yellow, '')

call s:h('ErrorMsg', s:fg, '', '')
call s:h('ModeMsg', s:fg, '', '')
call s:h('MoreMsg', s:fg, '', '')
call s:h('WarningMsg', s:red, '', '')
call s:h('Question', s:magenta, '', '')

call s:h('Pmenu', s:bg, s:fg, '')
call s:h('PmenuSel', s:fg, s:blue, '')
call s:h('PmenuSbar', '', s:selection, '')
call s:h('PmenuThumb', '', s:fg, '')

call s:h('SpellBad', s:red, '', '')
call s:h('SpellCap', s:yellow, '', '')
call s:h('SpellLocal', s:yellow, '', '')
call s:h('SpellRare', s:yellow, '', '')

call s:h('Visual', '', s:selection, '')
call s:h('VisualNOS', '', s:selection, '')

call s:h('ColorColumn', '', s:brblack, '')
call s:h('Conceal', s:fg, '', '')
call s:h('Directory', s:blue, '', '')
call s:h('WinSeparator', s:brblack, s:black, '')
call s:h('Folded', s:fg, '', '')
call s:h('FoldColumn', s:fg, '', '')
call s:h('LineNr', s:gutter_fg, s:gutter_bg, '')

call s:h('MatchParen', s:blue, '', 'underline')
call s:h('SpecialKey', s:fg, '', '')
call s:h('Title', s:green, '', '')
call s:h('WildMenu', s:fg, '', '')
" }


" Syntax colors {
" Whitespace is defined in Neovim, not Vim.
" See :help hl-Whitespace and :help hl-SpecialKey
call s:h('Whitespace', s:white, '', '')
call s:h('NonText', s:non_text, '', '')
call s:h('Comment', s:comment_fg, '', 'italic')
call s:h('Constant', s:cyan, '', '')
call s:h('String', s:green, '', '')
call s:h('Character', s:green, '', '')
call s:h('Number', s:yellow, '', '')
call s:h('Boolean', s:yellow, '', '')
call s:h('Float', s:yellow, '', '')

call s:h('Identifier', s:red, '', '')
call s:h('Function', s:blue, '', '')
call s:h('Statement', s:magenta, '', '')

call s:h('Conditional', s:magenta, '', '')
call s:h('Repeat', s:magenta, '', '')
call s:h('Label', s:magenta, '', '')
call s:h('Operator', s:fg, '', '')
call s:h('Keyword', s:red, '', '')
call s:h('Exception', s:magenta, '', '')

call s:h('PreProc', s:yellow, '', '')
call s:h('Include', s:magenta, '', '')
call s:h('Define', s:magenta, '', '')
call s:h('Macro', s:magenta, '', '')
call s:h('PreCondit', s:yellow, '', '')

call s:h('Type', s:yellow, '', '')
call s:h('StorageClass', s:yellow, '', '')
call s:h('Structure', s:yellow, '', '')
call s:h('Typedef', s:yellow, '', '')

call s:h('Special', s:blue, '', '')
call s:h('SpecialChar', s:fg, '', '')
call s:h('Tag', s:fg, '', '')
call s:h('Delimiter', s:fg, '', '')
call s:h('SpecialComment', s:fg, '', '')
call s:h('Debug', s:fg, '', '')
call s:h('Underlined', s:fg, '', '')
call s:h('Ignore', s:fg, '', '')
call s:h('Error', s:red, s:gutter_bg, '')
call s:h('Todo', s:magenta, '', '')
" }

" Colors in neovim terminal buffers {
if has('nvim')
  let g:terminal_color_0 = s:black.gui
  let g:terminal_color_1 = s:red.gui
  let g:terminal_color_2 = s:green.gui
  let g:terminal_color_3 = s:yellow.gui
  let g:terminal_color_4 = s:blue.gui
  let g:terminal_color_5 = s:magenta.gui
  let g:terminal_color_6 = s:cyan.gui
  let g:terminal_color_7 = s:white.gui
  let g:terminal_color_8 = s:brblack.gui
  let g:terminal_color_9 = s:brred.gui
  let g:terminal_color_10 = s:brgreen.gui
  let g:terminal_color_11 = s:bryellow.gui
  let g:terminal_color_12 = s:brblue.gui
  let g:terminal_color_13 = s:brmagenta.gui
  let g:terminal_color_14 = s:brcyan.gui
  let g:terminal_color_15 = s:brwhite.gui
  let g:terminal_color_background = s:bg.gui
  let g:terminal_color_foreground = s:fg.gui
endif
" }

" Diagnostics {
call s:h('DiagnosticError', s:red, '', '')
call s:h('DiagnosticWarn', s:warning_fg, '', '')
call s:h('DiagnosticInfo', s:blue, '', '')
call s:h('DiagnosticHint', s:cyan, '', '')
call s:h('DiagnosticSignError', s:red, s:brblack, '')
call s:h('DiagnosticSignWarn', s:yellow, s:brblack, '')
call s:h('DiagnosticSignInfo', s:blue, s:brblack, '')
call s:h('DiagnosticSignHint', s:cyan, s:brblack, '')
" }

" TabLine {
call s:h('TabLine', s:brwhite, s:brblack, '')
call s:h('TabLineFill', s:brwhite, s:brblack, '')
call s:h('TabLineSel', s:black, s:blue, '')
" }

" StatusLine {
call s:h('StatusLine', s:brwhite, s:brblack, '')
call s:h('StatusLineNC', s:white, s:black, '')
call s:h('StatusLineSub', s:black, s:white, '')
call s:h('StatusLineRed', s:black, s:red, '')
call s:h('StatusLineGreen', s:black, s:green, '')
call s:h('StatusLineYellow', s:black, s:yellow, '')
call s:h('StatusLineBlue', s:black, s:blue, '')
call s:h('StatusLineMagenta', s:black, s:magenta, '')
" }


" Plugins {
" GitSigns
highlight link SignColumn LineNr
call s:h('GitSignsAddNr', s:green, s:gutter_bg, '')
call s:h('GitSignsChangeNr', s:yellow, s:gutter_bg, '')
call s:h('GitSignsDeleteNr', s:red, s:gutter_bg, '')
" }
