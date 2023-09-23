set backupskip+=*.gpg

augroup encrypted
  autocmd!
  autocmd BufReadPre,FileReadPre *.gpg
    \ setlocal noswapfile bin
  autocmd BufReadPost,FileReadPost *.gpg
    \ execute '%!gpg --decrypt --default-recipient-self --quiet' |
    \ setlocal nobin |
    \ execute 'doautocmd BufReadPost ' . expand('%:r')
  autocmd BufWritePre,FileWritePre *.gpg
    \ setlocal bin |
    \ execute '%!gpg --encrypt --default-recipient-self --quiet'
  autocmd BufWritePost,FileWritePost *.gpg
    \ silent undo |
    \ setlocal nobin
augroup end
