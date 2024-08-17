-- Configure LSP servers
local cur_dir = os.getenv('PWD')
local is_local = not string.match(cur_dir, '^/media/sshfs/')

require('lspconfig').pyright.setup{autostart = is_local}
require('lspconfig').ruff_lsp.setup{autostart = is_local}
require('lspconfig').robotframework_ls.setup{
  autostart = is_local,
  settings = {
    robot = {
      lint = {robocop = {enabled = true}},
      variables = {execdir = cur_dir},
    },
  },
}
require('lspconfig').volar.setup{autostart = is_local}
require('lspconfig').tsserver.setup{
  autostart = is_local,
  init_options = {
    plugins = {
      {
        name = '@vue/typescript-plugin',
        location = './node_modules/@vue/typescript-plugin',
        languages = {'javascript', 'typescript', 'vue'},
      },
    },
  },
  filetypes = {'javascript', 'typescript', 'vue'},
}
require('lspconfig').rust_analyzer.setup{}

-- Diagnostics
vim.diagnostic.config({virtual_text = false, underline = true, severity_sort = true})

local opts = { noremap = true, silent = true }
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)

-- LSP features
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    -- omnifunc
    vim.api.nvim_buf_set_option(args.buf, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- mappings
    local bufopts = { noremap = true, silent = true, buffer = args.buf }
    vim.keymap.set('n', '<space>a', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', '<space>d', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', '<space>E', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<space>f', vim.lsp.buf.format, bufopts)
    vim.keymap.set('n', '<space>i', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', '<space>r', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', '<space>R', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<space>t', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', '<space>k', vim.lsp.buf.hover, bufopts)
  end,
})
