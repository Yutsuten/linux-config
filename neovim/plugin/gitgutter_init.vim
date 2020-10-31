scriptencoding utf-8

let g:gitgutter_highlight_linenrs = 1
let g:gitgutter_signs = 0
let g:gitgutter_sign_allow_clobber = 1

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
  autocmd VimEnter * call gitgutter#highlight#define_highlights()
augroup end

augroup gitguttertrigger
  autocmd!
  autocmd BufEnter,TextChanged,TextChangedI * GitGutter
augroup end
