vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- swapline
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = 'Edit: Move Down' })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = 'Edit: Move Up' })
vim.keymap.set("i", "<A-j>", "<Esc>:m .+1<CR>==gi", { desc = 'Edit: Move Down' })
vim.keymap.set("i", "<A-k>", "<Esc>:m .-2<CR>==gi", { desc = 'Edit: Move Up' })

-- move lines
vim.keymap.set("n", "J", "mzJ`z", { desc = 'Edit: Join Lines' })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = 'View: Half Page Down' })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = 'View: Half Page Up' })
vim.keymap.set("n", "n", "nzzzv", { desc = 'Search: Next Result' })
vim.keymap.set("n", "N", "Nzzzv", { desc = 'Search: Prev Result' })

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = 'Clipboard: Paste Without Yank' })

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = 'Clipboard: Yank to System Clipboard' })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = 'Clipboard: Yank Line to System Clipboard' })

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = 'Edit: Delete Without Yank' })

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>", { desc = 'Insert: Escape' })
-- JK
vim.keymap.set("i", "jk", "<Esc>l", { desc = 'Insert: Escape via Combo' })
vim.keymap.set("i", "kj", "<Esc>l", { desc = 'Insert: Escape via Combo' })
vim.keymap.set("i", "JK", "<Esc>l", { desc = 'Insert: Escape via Combo' })
vim.keymap.set("i", "KJ", "<Esc>l", { desc = 'Insert: Escape via Combo' })
vim.keymap.set("i", "jK", "<Esc>l", { desc = 'Insert: Escape via Combo' })
vim.keymap.set("i", "Kj", "<Esc>l", { desc = 'Insert: Escape via Combo' })
vim.keymap.set("i", "Jk", "<Esc>l", { desc = 'Insert: Escape via Combo' })
vim.keymap.set("i", "kJ", "<Esc>l", { desc = 'Insert: Escape via Combo' })

vim.keymap.set("n", "Q", "<nop>", { desc = 'UI: Disable Ex Mode' })
vim.keymap.set("n", "<leader>bf", vim.lsp.buf.format, { desc = 'Buffer: Format' })

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz", { desc = 'Quickfix: Next Entry' })
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz", { desc = 'Quickfix: Prev Entry' })
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz", { desc = 'Quickfix: Next Item' })
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz", { desc = 'Quickfix: Prev Item' })

vim.keymap.set("n", "<leader>rw", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = 'Refactor: Replace Word Under Cursor' })
vim.keymap.set("n", "<leader>bx", "<cmd>!chmod +x %<CR>", { silent = true, desc = 'Buffer: Make Executable' })

vim.keymap.set("n", "<leader>bs", function()
  vim.cmd("so")
end, { desc = 'Buffer: Source Current File' })

-- git status
vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = 'Git: Status' })

-- undotree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = 'UI: Toggle UndoTree' })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- open file manager
vim.keymap.set("n", "<leader>pv", function()
  vim.cmd('cd %:p:h')
  vim.cmd('Explore')
end, { desc = 'Project: Open netrw Here' })



-- https://neovim.io/doc/user/nvim_terminal_emulator.html
vim.keymap.set("n", "<leader>tt", "<cmd>vsplit term://zsh<CR>a", { desc = 'Terminal: Toggle Split' })

-- delete buffer
vim.keymap.set("n", "<leader>bd", "<cmd>bd<CR>", { desc = 'Buffer: Delete' })

vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = 'Terminal: Escape Mode' })

-- switch window terminal mode
vim.keymap.set("t", "<A-h>", "<C-\\><C-N><C-w>h", { desc = 'Terminal: Window Left' })
vim.keymap.set("t", "<A-j>", "<C-\\><C-N><C-w>j", { desc = 'Terminal: Window Down' })
vim.keymap.set("t", "<A-k>", "<C-\\><C-N><C-w>k", { desc = 'Terminal: Window Up' })
vim.keymap.set("t", "<A-l>", "<C-\\><C-N><C-w>l", { desc = 'Terminal: Window Right' })

-- switch window normal mode
vim.keymap.set("n", "<A-h>", "<C-\\><C-N><C-w>h", { desc = 'Window: Go Left' })
vim.keymap.set("n", "<A-j>", "<C-\\><C-N><C-w>j", { desc = 'Window: Go Down' })
vim.keymap.set("n", "<A-k>", "<C-\\><C-N><C-w>k", { desc = 'Window: Go Up' })
vim.keymap.set("n", "<A-l>", "<C-\\><C-N><C-w>l", { desc = 'Window: Go Right' })
