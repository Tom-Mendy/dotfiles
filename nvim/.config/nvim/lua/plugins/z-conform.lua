return {
	"stevearc/conform.nvim",
	dependencies = { "zapling/mason-conform.nvim" },
	-- event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")
		local command_exists = require("utils").command_exists

		local formatters_list = {
			lua = { "stylua" },
			markdown = { "mdformat" },
			bash = { "beautysh" },
			yaml = { "yamlfix" },
			toml = { "taplo" },
			css = { "prettierd", "prettier" },
			sh = { "shellcheck" },
			-- Use the "*" filetype to run formatters on all filetypes.
			["*"] = { "codespell" },
			-- Use the "_" filetype to run formatters on filetypes that don't
			-- have other formatters configured.
			["_"] = { "trim_whitespace" },
		}
		if command_exists("npm") then
			formatters_list.javascript = { "prettierd", "prettier" }
			formatters_list.typescript = { "prettierd", "prettier" }
			formatters_list.javascriptreact = { "prettierd", "prettier" }
			formatters_list.typescriptreact = { "prettierd", "prettier" }
			formatters_list.svelte = { "prettierd", "prettier" }
		end
		if command_exists("go") then
			formatters_list.go = { "gofumpt", "goimports" }
		end
		if command_exists("cargo") then
			formatters_list.rust = { "rustfmt" }
		end
		conform.setup({
			formatters_by_ft = formatters_list,
			-- Set this to change the default values when calling conform.format()
			-- This will also affect the default values for format_on_save/format_after_save
			default_format_opts = {
				lsp_format = "fallback",
			},
			-- If this is set, Conform will run the formatter on save.
			-- It will pass the table to conform.format().
			-- This can also be a function that returns the table.
			format_on_save = {
				-- I recommend these options. See :help conform.format for details.
				lsp_format = "fallback",
				timeout_ms = 500,
			},
			-- If this is set, Conform will run the formatter asynchronously after save.
			-- It will pass the table to conform.format().
			-- This can also be a function that returns the table.
			format_after_save = {
				lsp_format = "fallback",
			},
			-- Set the log level. Use `:ConformInfo` to see the location of the log file.
			log_level = vim.log.levels.ERROR,
			-- Conform will notify you when a formatter errors
			notify_on_error = true,
			-- Conform will notify you when no formatters are available for the buffer
			notify_no_formatters = true,
		})

		vim.keymap.set({ "n", "v" }, "<leader>f", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "Format file or range (in visual mode)" })

		require("mason-conform").setup()
	end,
}
