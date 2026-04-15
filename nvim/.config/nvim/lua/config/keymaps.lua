-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

map("n", "J", "mzJ`z", { desc = "Join lines" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up" })

map("x", "<leader>P", [["_dP]], { desc = "Paste without yank" })
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })

map("n", "]l", "<cmd>lnext<CR>zz", { desc = "Next location-list entry" })
map("n", "[l", "<cmd>lprev<CR>zz", { desc = "Previous location-list entry" })

map(
  "n",
  "<leader>sR",
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Replace word under cursor" }
)

map("n", "<leader>fx", "<cmd>!chmod +x %<CR>", { desc = "Make current file executable", silent = true })
map("n", "<leader>gs", "<cmd>Git<CR>", { desc = "Git status" })
map("n", "<leader>wt", "<cmd>vsplit | terminal<CR>", { desc = "Terminal split" })
map("n", "<leader>bu", "<cmd>UndotreeToggle<CR>", { desc = "Undo tree" })
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

map("n", "<A-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<A-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<A-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<A-l>", "<C-w>l", { desc = "Go to right window" })
