vim.opt.guicursor = ""

-- Enable mouse mode
vim.opt.mouse = 'a'

-- disable default File Explorer
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Make line numbers default
vim.opt.nu = true
vim.opt.relativenumber = true

-- Global indentation settings for all filetypes
vim.opt.expandtab = true    -- Use spaces instead of tabs
vim.opt.shiftwidth = 2      -- Number of spaces to use for each step of (auto)indent
vim.opt.softtabstop = 2     -- Number of spaces a <Tab> counts for
vim.opt.tabstop = 2         -- Number of spaces that a <Tab> in the file counts for

-- Enable break indent
vim.opt.breakindent = true
vim.opt.smartindent = true

-- Disable wrap line
vim.opt.wrap = false

-- Save undo history
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- Set highlight on search
vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

-- Decrease update time
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

vim.o.completeopt = 'menuone,noselect'

vim.opt.colorcolumn = "80"

vim.opt.cul = true

vim.opt.encoding = "UTF-8"

-- Case-insensitive searching UNLESS \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.wildignore = "__pycache__"
vim.opt.wildignore:append { "*.o", "*~", "*.pyc", "*pycache*" }
vim.opt.wildignore:append "Cargo.lock"
