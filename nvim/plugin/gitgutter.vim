let g:gitgutter_highlight_linenrs = 1

augroup gitgutterhighlight
  autocmd!
  autocmd VimEnter * highlight! link SignColumn LineNr
  autocmd VimEnter * highlight GitGutterAdd ctermbg=0
  autocmd VimEnter * highlight GitGutterChange ctermbg=0
  autocmd VimEnter * highlight GitGutterDelete ctermbg=0
  autocmd VimEnter * highlight GitGutterChangeDelete ctermbg=0 ctermfg=9
  autocmd VimEnter * highlight GitGutterAddLineNr ctermbg=0 ctermfg=2
  autocmd VimEnter * highlight GitGutterChangeLineNr ctermbg=0 ctermfg=3
  autocmd VimEnter * highlight GitGutterDeleteLineNr ctermbg=0 ctermfg=1
  autocmd VimEnter * highlight GitGutterChangeDeleteLineNr ctermbg=0 ctermfg=9
augroup end
