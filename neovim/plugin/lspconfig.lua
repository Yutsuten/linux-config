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
local signs = {
  Error = " ✗",
  Warning = " ‼",
  Information = " 𝒾",
  Hint = " 𝒾",
}

for type, icon in pairs(signs) do
  local hl = "LspDiagnosticsSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl })
end

vim.cmd [[
  highlight LspDiagnosticsSignError ctermfg=1 ctermbg=0
  highlight LspDiagnosticsSignWarning ctermfg=3 ctermbg=0
  highlight LspDiagnosticsSignInformation ctermfg=13 ctermbg=0
  highlight LspDiagnosticsSignHint ctermfg=13 ctermbg=0
]]

-- diagnostics virtual text
vim.diagnostic.config({virtual_text = false})
