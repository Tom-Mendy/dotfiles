return {
	-- Highlight, edit, and navigate code
	"nvim-treesitter/nvim-treesitter",
	opts = function(_, opts)
		opts.ensure_installed = opts.ensure_installed or {}
		local wanted = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "jsonc" }
		for _, lang in ipairs(wanted) do
			if not vim.tbl_contains(opts.ensure_installed, lang) then
				table.insert(opts.ensure_installed, lang)
			end
		end
	end,
}
