require('gitsigns').setup({
  signcolumn = false,
  numhl      = true,
})

vim.cmd([[
  highlight! link SignColumn LineNr
  highlight GitSignsAddNr ctermbg=0 ctermfg=2
  highlight GitSignsChangeNr ctermbg=0 ctermfg=3
  highlight GitSignsDeleteNr ctermbg=0 ctermfg=9
]])
