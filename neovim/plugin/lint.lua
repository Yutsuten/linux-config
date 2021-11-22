require('lint').linters_by_ft = {
  javascript = {'eslint'},
  python = {'pylint', 'flake8'},
  sh = {'shellcheck'},
  vim = {'vint'},
}

vim.cmd([[
  autocmd BufEnter,TextChanged,BufWritePost * lua require('lint').try_lint()
]])
