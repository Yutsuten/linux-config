-- omnifunc
vim.api.nvim_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

-- mappings
local opts = { noremap=true, silent=true }
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>d', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>r', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>k', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)

-- setup lsp servers
require('lspconfig').pylsp.setup{
  settings = {
    pylsp = {
      configurationSources = {'flake8'}
    }
  }
}

-- diagnostics signs
vim.cmd([[
  highlight LspDiagnosticsLineNrError ctermfg=1 ctermbg=0
  highlight LspDiagnosticsLineNrWarning ctermfg=3 ctermbg=0
  highlight LspDiagnosticsLineNrInformation ctermfg=13 ctermbg=0
  highlight LspDiagnosticsLineNrHint ctermfg=13 ctermbg=0

  sign define LspDiagnosticsSignError text= texthl=LspDiagnosticsSignError linehl= numhl=LspDiagnosticsLineNrError
  sign define LspDiagnosticsSignWarning text= texthl=LspDiagnosticsSignWarning linehl= numhl=LspDiagnosticsLineNrWarning
  sign define LspDiagnosticsSignInformation text= texthl=LspDiagnosticsSignInformation linehl= numhl=LspDiagnosticsLineNrInformation
  sign define LspDiagnosticsSignHint text= texthl=LspDiagnosticsSignHint linehl= numhl=LspDiagnosticsLineNrHint
]])
