-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.wrap = false
vim.opt.colorcolumn = "80"
vim.opt.scrolloff = 8
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("state") .. "/undo"
vim.opt.timeoutlen = 300
vim.opt.updatetime = 250
vim.opt.ignorecase = true
vim.opt.smartcase = true
