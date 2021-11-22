require('gitsigns').setup({
  signs = {
      add          = {hl = 'GitSignsAdd'   , text = ' │'},
      change       = {hl = 'GitSignsChange', text = ' │'},
      delete       = {hl = 'GitSignsDelete', text = ' │'},
      topdelete    = {hl = 'GitSignsDelete', text = ' │'},
      changedelete = {hl = 'GitSignsChange', text = ' │'},
  }
})

vim.cmd([[
  highlight! link SignColumn LineNr
  highlight GitSignsAdd ctermbg=0 ctermfg=2
  highlight GitSignsChange ctermbg=0 ctermfg=3
  highlight GitSignsDelete ctermbg=0 ctermfg=9
]])
