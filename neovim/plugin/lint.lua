require('lint').linters_by_ft = {
  python = {'pylint', 'flake8'},
}

vim.cmd([[
  autocmd BufEnter,TextChanged,BufWritePost * lua require('lint').try_lint()
]])
