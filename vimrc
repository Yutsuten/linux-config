filetype plugin indent on
set nocp
set showcmd
set is ic
set updatetime=250
set number
set noshowmode
set splitbelow
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set hidden
set mouse=a
set exrc
set secure
syntax enable

set fileencodings=iso-2022-jp,euc-jp,cp932,utf8,default,latin1
set encoding=utf8

set background=dark
colorscheme solarized

let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 1
set ttimeoutlen=20

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_loc_list_height = 5

autocmd BufEnter * EnableStripWhitespaceOnSave
autocmd CompleteDone * pclose
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | NERDTree | endif
highlight link NERDTreeExecFile ModeMsg

autocmd FileType vue syntax sync fromstart

let g:ft = ''
function! NERDCommenter_before()
  if &ft == 'vue'
    let g:ft = 'vue'
    let stack = synstack(line('.'), col('.'))
    if len(stack) > 0
      let syn = synIDattr((stack)[0], 'name')
      if len(syn) > 0
        exe 'setf ' . substitute(tolower(syn), '^vue_', '', '')
      endif
    endif
  endif
endfunction
function! NERDCommenter_after()
  if g:ft == 'vue'
    setf vue
    let g:ft = ''
  endif
endfunction

if has('macunix')
  set background=light
endif

if has('gui_running')
  set guifont=Liberation\ Mono\ for\ Powerline\ 10
  if has('macunix')
    set guifont=Meslo\ LG\ S\ for\ Powerline:h12
  endif
endif
