require('lint').linters_by_ft = {
  javascript = {'eslint'},
  javascriptreact = {'eslint'},
  typescript = {'eslint'},
  typescriptreact = {'eslint'},
  markdown = {'eslint'},
  vue = {'eslint', 'stylelint'},
  sh = {'shellcheck'},
  vim = {'vint'},
  lua = {'luacheck'},
  yaml = {'yamllint'},
}

vim.cmd([[
  autocmd BufEnter,TextChanged,BufWritePost * lua require('lint').try_lint()
]])
