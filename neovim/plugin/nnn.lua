require('nnn').setup({
  picker = {
    style = { border = 'double' },
  }
})

local opts = { noremap=true, silent=true }
vim.api.nvim_set_keymap('n', '<leader>N', '<cmd>NnnPicker<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>n', '<cmd>NnnPicker %:p:h<CR>', opts)

vim.cmd [[
  highlight NnnBorder ctermfg=10 ctermbg=NONE
]]
