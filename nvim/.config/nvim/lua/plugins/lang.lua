local function has(bin)
  return vim.fn.executable(bin) == 1
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}

      if has("go") then
        opts.servers.gopls = opts.servers.gopls or {}
      end
      if has("cargo") then
        opts.servers.rust_analyzer = opts.servers.rust_analyzer or {}
      end
      if has("gcc") then
        opts.servers.clangd = opts.servers.clangd or {}
      end
      if has("docker") or has("podman") then
        opts.servers.dockerls = opts.servers.dockerls or {}
        opts.servers.docker_compose_language_service = opts.servers.docker_compose_language_service or {}
      end
      if has("python3") or has("python") then
        opts.servers.pyright = opts.servers.pyright or {}
      end
      if has("marksman") then
        opts.servers.marksman = opts.servers.marksman or {}
      end
      if has("node") or has("npm") then
        opts.servers.bashls = opts.servers.bashls or {}
        opts.servers.vtsls = opts.servers.vtsls or {}
      end

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
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}

      opts.formatters_by_ft.lua = { "stylua" }
      opts.formatters_by_ft.c = { "clang-format" }
      opts.formatters_by_ft.cpp = { "clang-format" }

      if has("prettierd") or has("prettier") then
        opts.formatters_by_ft.javascript = { "prettierd", "prettier" }
        opts.formatters_by_ft.typescript = { "prettierd", "prettier" }
        opts.formatters_by_ft.javascriptreact = { "prettierd", "prettier" }
        opts.formatters_by_ft.typescriptreact = { "prettierd", "prettier" }
        opts.formatters_by_ft.svelte = { "prettierd", "prettier" }
      end
      if has("gofumpt") or has("goimports") then
        opts.formatters_by_ft.go = { "gofumpt", "goimports" }
      end
      if has("rustfmt") then
        opts.formatters_by_ft.rust = { "rustfmt" }
      end
      if has("mdformat") then
        opts.formatters_by_ft.markdown = { "mdformat" }
      end

      opts.default_format_opts = vim.tbl_deep_extend("force", opts.default_format_opts or {}, {
        lsp_format = "fallback",
      })
      opts.format_on_save = vim.tbl_deep_extend("force", opts.format_on_save or {}, {
        timeout_ms = 500,
        lsp_format = "fallback",
      })
    end,
  },
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        svelte = { "eslint_d" },
        markdown = { "markdownlint" },
      }

      local group = vim.api.nvim_create_augroup("custom_nvim_lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = group,
        callback = function()
          lint.try_lint()
        end,
      })

      vim.keymap.set("n", "<leader>cl", function()
        lint.try_lint()
      end, { desc = "Lint current file" })
    end,
  },
}
