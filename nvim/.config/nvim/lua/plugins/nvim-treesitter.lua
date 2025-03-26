return {
	-- Highlight, edit, and navigate code
	"nvim-treesitter/nvim-treesitter",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
		"nvim-treesitter/nvim-treesitter-context",
	},
	build = ":TSUpdate",
	config = function()
		local conform = require("conform")

		conform.setup({
			ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "jsonc" },
		})
	end,
}
