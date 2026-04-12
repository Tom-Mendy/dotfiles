return {
	"nvim-neo-tree/neo-tree.nvim",
	keys = {
		{
			"<leader>pf",
			function()
				require("neo-tree.command").execute({ source = "filesystem", reveal = true, position = "right" })
			end,
			desc = "Project Filesystem",
		},
	},
	opts = function(_, opts)
		opts.close_if_last_window = true
		opts.window = vim.tbl_deep_extend("force", opts.window or {}, {
			position = "right",
			width = 30,
		})
		opts.filesystem = vim.tbl_deep_extend("force", opts.filesystem or {}, {
			filtered_items = {
				visible = true,
				hide_dotfiles = false,
				hide_gitignored = false,
			},
			follow_current_file = {
				enabled = true,
				leave_dirs_open = true,
			},
		})
	end,
}
