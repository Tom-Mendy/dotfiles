return {
	"LhKipp/nvim-nu",
	build = ":TSInstall nu",
	config = function()
		require("nu").setup({
			use_lsp_features = true, -- requires https://github.com/jose-elias-alvarez/null-ls.nvim
			-- lsp_feature: all_cmd_names is the source for the cmd name completion.
			-- It can be
			--  * a string, which is evaluated by nushell and the returned list is the source for completions (requires plenary.nvim)
			--  * a list, which is the direct source for completions (e.G. all_cmd_names = {"echo", "to csv", ...})
			--  * a function, returning a list of strings and the return value is used as the source for completions
			all_cmd_names = [[help commands | get name | str join "\n"]],
		})
	end,
}
