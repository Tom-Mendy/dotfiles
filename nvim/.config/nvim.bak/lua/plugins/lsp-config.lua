return {
	{
		"neovim/nvim-lspconfig",
		opts = function(_, opts)
			local command_exists = require("utils").command_exists
			opts.servers = opts.servers or {}

			if command_exists("go") then
				opts.servers.gopls = opts.servers.gopls or {}
			end
			if command_exists("npm") then
				opts.servers.ts_ls = opts.servers.ts_ls or {}
			end
			if command_exists("cargo") then
				opts.servers.rust_analyzer = opts.servers.rust_analyzer or {}
			end
			if command_exists("gcc") then
				opts.servers.clangd = opts.servers.clangd or {}
			end
			if command_exists("docker") or command_exists("podman") then
				opts.servers.dockerls = opts.servers.dockerls or {}
				opts.servers.docker_compose_language_service = opts.servers.docker_compose_language_service or {}
			end
			if command_exists("python") then
				opts.servers.pyright = opts.servers.pyright or {}
			end
			if command_exists("nix") then
				opts.servers.rnix = opts.servers.rnix or {}
			end

			opts.servers.bashls = opts.servers.bashls or {}
			opts.servers.bashls.enabled = command_exists("node")

			opts.servers.html = vim.tbl_deep_extend("force", opts.servers.html or {}, {
				filetypes = { "html", "twig", "hbs" },
			})

			opts.servers.lua_ls = vim.tbl_deep_extend("force", opts.servers.lua_ls or {}, {
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
					},
				},
			})
		end,
	},
}
