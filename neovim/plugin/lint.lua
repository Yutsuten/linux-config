require('lint').linters_by_ft = {
  javascript = {'eslint'},
  typescript = {'eslint'},
  python = {'pylint'},
  robot = {'robocop'},
  sh = {'shellcheck'},
  vim = {'vint'},
  lua = {'luacheck'},
  yaml = {'yamllint'}
}

vim.cmd([[
  autocmd BufEnter,TextChanged,BufWritePost * lua require('lint').try_lint()
]])
