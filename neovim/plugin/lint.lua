require('lint').linters_by_ft = {
  javascript = {'eslint'},
  python = {'pylint'},
  robot = {'robocop'},
  sh = {'shellcheck'},
  vim = {'vint'},
}

vim.cmd([[
  autocmd BufEnter,TextChanged,BufWritePost * lua require('lint').try_lint()
]])
