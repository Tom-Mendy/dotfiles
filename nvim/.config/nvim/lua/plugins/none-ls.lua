return {
	"nvimtools/none-ls.nvim",
	optional = true,
	opts = function(_, opts)
		local nls = require("null-ls")
		opts.sources = vim.list_extend(opts.sources or {}, {
			nls.builtins.formatting.stylua,
			nls.builtins.formatting.clang_format,
		})
	end,
}
