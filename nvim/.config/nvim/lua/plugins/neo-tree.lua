return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		vim.keymap.set("n", "<leader>pf", ":Neotree filesystem reveal right<CR>", { desc = "[P]roject [F]ilesystem" })
		-- vim.keymap.set("n", "<leader>pf", function()
		--     vim.cmd('cd %:p:h')
		--     vim.cmd('NvimTreeFocus')
		-- end, { desc = '[P]roject [F]ilesystem' })

		vim.api.nvim_create_autocmd("BufEnter", {
			pattern = "*",
			callback = function()
				local buftype = vim.api.nvim_buf_get_option(0, "buftype")
				if buftype == "" and #vim.api.nvim_list_wins() > 1 then
					vim.cmd("Neotree close")
				end
			end,
		})
		require("neo-tree").setup({
			disable_netrw = true,
			hijack_netrw = true,
			open_on_setup = true,
			auto_close = true,
			update_focused_file = {
				enable = true,
				update_cwd = true,
			},
			view = {
				width = 30,
				side = "right",
				auto_resize = false,
			},
			close_if_last_window = true,
			filesystem = {
				filtered_items = {
					visible = true, -- Always show hidden files
					hide_dotfiles = false, -- Do not hide dotfiles
					hide_gitignored = false, -- Do not hide gitignored files
				},
				follow_current_file = {
					enabled = true,
					leave_dirs_open = true,
				},
			},
		})
	end,
}
