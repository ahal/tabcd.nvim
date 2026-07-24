local tests_dir = vim.fn.getcwd() .. "/.tests"

vim.opt.rtp:prepend(vim.fn.getcwd())
vim.opt.rtp:prepend(tests_dir .. "/plenary.nvim")
vim.opt.rtp:prepend(tests_dir .. "/telescope.nvim")
vim.opt.rtp:prepend(tests_dir .. "/snacks.nvim")
vim.opt.rtp:prepend(tests_dir .. "/fzf-lua")

vim.cmd("runtime plugin/plenary.vim")
