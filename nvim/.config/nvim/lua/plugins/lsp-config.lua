return {
	"neovim/nvim-lspconfig",
	dependencies = {
		-- Automatically install LSPs to stdpath for neovim
		{ "williamboman/mason.nvim", config = true },
		"williamboman/mason-lspconfig.nvim",

		-- Useful status updates for LSP
		-- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
		{ "j-hui/fidget.nvim", tag = "legacy", opts = {} },

		-- Additional lua configuration, makes nvim stuff amazing!
		"folke/neodev.nvim",
		"rshkarin/mason-nvim-lint",
	},
	config = function()
		require("neodev").setup()
		local on_attach = function(_, bufnr)
			-- NOTE: Remember that lua is a real programming language, and as such it is possible
			-- to define small helper and utility functions so you don't have to repeat yourself
			-- many times.
			--
			-- In this case, we create a function that lets us more easily define mappings specific
			-- for LSP related items. It sets the mode, buffer and description for us each time.
			local nmap_lsp = function(keys, func, desc)
				if desc then
					desc = "LSP: " .. desc
				end

				vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
			end

			nmap_lsp("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
			nmap_lsp("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

			nmap_lsp("gd", vim.lsp.buf.definition, "[G]oto [D]definition")
			nmap_lsp("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
			nmap_lsp("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
			nmap_lsp("<leader>D", vim.lsp.buf.type_definition, "Type [D]definition")
			nmap_lsp("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]symbols")
			nmap_lsp("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]symbols")

			-- See `:help K` for why this keymap
			nmap_lsp("K", vim.lsp.buf.hover, "Hover Documentation")
			nmap_lsp("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

			-- Lesser used LSP functionality
			nmap_lsp("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
			nmap_lsp("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
			nmap_lsp("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
			nmap_lsp("<leader>wl", function()
				print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
			end, "[W]orkspace [L]ist Folders")

			-- Create a command `:Format` local to the LSP buffer
			vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
				vim.lsp.buf.format()
			end, { desc = "Format current buffer with LSP" })
		end

		-- Enable the following language servers
		--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
		--
		--  Add any additional override configuration in the following tables. They will be passed to
		--  the `settings` field of the server config. You must look up that documentation yourself.
		--
		--  If you want to override the default filetypes that your language server will attach to you can
		--  define the property 'filetypes' to the map in question.
		local command_exists = require("utils").command_exists

		local servers = {}
		if command_exists("go") then
			servers.gopls = {}
		end
		if command_exists("npm") then
			servers.ts_ls = {}
		end
		if command_exists("cargo") then
			servers.rust_analyzer = {}
		end
		if command_exists("gcc") then
			servers.clangd = {}
		end
		if command_exists("docker") or command_exists("podman") then
			servers.dockerls = {}
			servers.docker_compose_language_service = {}
		end
		if command_exists("python") then
			servers.pyright = {}
		end
		if command_exists("nix") then
			servers.rnix = {} -- Nix language server
		end

		servers = {
			html = { filetypes = { "html", "twig", "hbs" } },
			lua_ls = {
				Lua = {
					diagnostics = {
						-- Get the language server to recognize the `vim` global
						globals = { "vim" },
					},
				},
			},
		}

		-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

		local mason = require("mason")
		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		-- Ensure the servers above are installed
		local mason_lspconfig = require("mason-lspconfig")
		mason_lspconfig.setup({
			ensure_installed = vim.tbl_keys(servers),
			automatic_installation = true,
		})

		mason_lspconfig.setup_handlers({
			function(server_name)
				require("lspconfig")[server_name].setup({
					capabilities = capabilities,
					on_attach = on_attach,
					settings = servers[server_name],
					filetypes = (servers[server_name] or {}).filetypes,
				})
			end,
		})
		require("mason-nvim-lint").setup()
	end,
}
