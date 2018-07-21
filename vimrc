filetype plugin indent on
set nocp
set showcmd
set ignorecase
set smartcase
set hlsearch
set incsearch
set updatetime=250
set colorcolumn=100
set number
set noshowmode
set splitbelow
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set hidden
set mouse=a
set autoread
set exrc
set secure
syntax enable

set fileencodings=utf8,iso-2022-jp,euc-jp,cp932,default,latin1
set encoding=utf8

set background=light
colorscheme solarized

let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 1
set laststatus=2
set ttimeoutlen=20

autocmd BufEnter * EnableStripWhitespaceOnSave
autocmd CompleteDone * pclose
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | Explore | endif
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

if has('gui_running')
  set guifont=Liberation\ Mono\ for\ Powerline\ 11
  set guioptions-=m  "remove menu bar
  set guioptions-=T  "remove toolbar
  if has('macunix')
    set guifont=Meslo\ LG\ S\ for\ Powerline:h13
  endif
endif
