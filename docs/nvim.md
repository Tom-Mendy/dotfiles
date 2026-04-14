# Neovim Config

This directory contains the active Neovim configuration used in this repo.

## Architecture

- Entry point: `init.lua`
- Plugin manager: `lazy.nvim`
- Base distro: `LazyVim`
- Customizations: `lua/keymaps.lua`, `lua/option.lua`, `lua/plugins/*.lua`
- Lockfile: `lazy-lock.json`

`init.lua` bootstraps `lazy.nvim` directly and imports:

- `LazyVim/LazyVim`
- all plugin specs from `lua/plugins`

The older [`lua/lazy.lua`](./lua/lazy.lua) file exists in the tree, but `init.lua` is the real source of truth.

## Core Behavior

Global editor defaults from [`lua/option.lua`](./lua/option.lua):

- leader key is space
- mouse enabled
- relative line numbers enabled
- 2-space indentation by default
- C and C++ override indentation to 4 spaces in `ftplugin/c.lua` and `ftplugin/cpp.lua`
- no swapfile or backup
- persistent undo enabled in `~/.vim/undodir`
- search is case-insensitive unless the pattern contains capitals
- splits open right and below
- wrap disabled
- color column at 80
- cursorline enabled
- `termguicolors` enabled

## Keymaps

Custom mappings are defined in [`lua/keymaps.lua`](./lua/keymaps.lua). Highlights:

- `<A-j>` / `<A-k>`: move lines in visual or insert mode
- `jk`, `kj` and case variants in insert mode: leave insert mode
- `<leader>y`: yank to system clipboard
- `<leader>d`: delete without yanking
- `<leader>rw`: substitute word under cursor
- `<leader>bx`: `chmod +x` current file
- `<leader>bs`: source current file
- `<leader>bd`: delete buffer
- `<leader>u`: toggle Undotree
- `<leader>tt`: open a vertical terminal running `zsh`
- `<leader>gs`: open Fugitive git status
- `<leader>bf`: `vim.lsp.buf.format()`
- `<leader>f`: format via Conform
- `<leader>ll`: run `nvim-lint`
- `<leader>pf`: open Neo-tree file explorer on the right
- `<leader>pv`: runs `:Explore` in the current file directory
- `<A-h/j/k/l>`: window navigation
- terminal mode `<Esc>`: return to normal mode

`which-key.nvim` groups several prefixes: `b`, `f`, `g`, `l`, `p`, `r`, `t`.

## Plugins In Use

This config extends LazyVim with the following custom plugin specs.

### UI and navigation

- `folke/tokyonight.nvim`
- `nvim-lualine/lualine.nvim`
- `akinsho/bufferline.nvim`
- `folke/which-key.nvim`
- `nvim-neo-tree/neo-tree.nvim`
- `lukas-reineke/indent-blankline.nvim`
- `MeanderingProgrammer/render-markdown.nvim`

### Editing

- `numToStr/Comment.nvim`
- `windwp/nvim-autopairs`
- `tpope/vim-surround`
- `tpope/vim-sleuth`
- `mbbill/undotree`

### Search and git

- `nvim-telescope/telescope.nvim` with optional `telescope-fzf-native.nvim`
- `lewis6991/gitsigns.nvim`
- `tpope/vim-fugitive`
- `tpope/vim-rhubarb`
- `tpope/vim-obsession`
- `folke/todo-comments.nvim`

### Language support and tooling

- `nvim-treesitter/nvim-treesitter`
- `neovim/nvim-lspconfig`
- `stevearc/conform.nvim`
- `nvimtools/none-ls.nvim` via LazyVim extra
- `mfussenegger/nvim-lint`
- `github/copilot.vim`
- `wakatime/vim-wakatime`
- `LhKipp/nvim-nu`
- `esensar/nvim-dev-container`

## LSP Setup

LSP servers are enabled conditionally in [`lua/plugins/lsp-config.lua`](./lua/plugins/lsp-config.lua) based on available executables:

- `gopls` if `go` exists
- `ts_ls` if `npm` exists
- `rust_analyzer` if `cargo` exists
- `clangd` if `gcc` exists
- `dockerls` and `docker_compose_language_service` if `docker` or `podman` exists
- `pyright` if `python` exists
- `rnix` if `nix` exists
- `bashls` if `node` exists
- `html` for `html`, `twig`, and `hbs`
- `lua_ls` with `vim` added as a recognized global

Because the setup is conditional, installed CLIs matter as much as the Neovim config itself.

## Formatting

Formatting is handled by `conform.nvim` in [`lua/plugins/z-conform.lua`](./lua/plugins/z-conform.lua).

- format on save is enabled
- `<leader>f` formats the current buffer or selection
- LSP formatting falls back when no dedicated formatter exists

Configured formatters:

- Lua: `stylua`
- Markdown: `mdformat`
- Bash: `beautysh`
- YAML: `yamlfix`
- TOML: `taplo`
- CSS: `prettierd` or `prettier`
- Shell: `shellcheck`
- all filetypes: `codespell`
- fallback: `trim_whitespace`

Conditional formatters:

- JavaScript / TypeScript / React / Svelte: `prettierd` or `prettier` when `npm` exists
- Go: `gofumpt`, `goimports` when `go` exists
- Rust: `rustfmt` when `cargo` exists

## Linting

Linting is handled by [`lua/plugins/nvim-lint.lua`](./lua/plugins/nvim-lint.lua).

- runs on `BufEnter`, `BufWritePost`, and `InsertLeave`
- `<leader>ll` runs linting manually

Configured linters:

- JavaScript / TypeScript / React / Svelte: `eslint_d`
- Markdown: `markdownlint`

## Treesitter

The config ensures these parsers are installed if missing:

- `c`
- `lua`
- `vim`
- `vimdoc`
- `query`
- `markdown`
- `markdown_inline`
- `jsonc`

## Telescope Behavior

[`lua/plugins/telescope.lua`](./lua/plugins/telescope.lua) customizes Telescope to:

- include hidden files
- follow symlinks during grep
- ignore common heavy directories like `.git`, `.idea`, `.vscode`, `build`, `dist`
- ignore `yarn.lock` and `package-lock.json` in search/file listing

## Git Integration

Git support is split across several plugins:

- Fugitive for `:Git` and `<leader>gs`
- Gitsigns for gutter indicators and hunk navigation
- `<leader>gp`: previous hunk
- `<leader>gn`: next hunk
- `<leader>ph`: preview hunk

## External Dependencies

This config assumes some tools are installed on the system if you want full functionality:

- `git`
- `rg`
- `make` for `telescope-fzf-native.nvim`
- language runtimes and CLIs such as `node`, `npm`, `go`, `cargo`, `python`, `docker`, `podman`, `nix`
- formatter and linter binaries such as `stylua`, `prettierd`, `prettier`, `mdformat`, `yamlfix`, `taplo`, `eslint_d`, `markdownlint`

## Maintenance

Update plugins:

```vim
:Lazy update
```

Review available updates:

```vim
:Lazy check
```

Restore from the lockfile after a bad update:

```vim
:Lazy restore
```

## Notes

- Copilot is installed through `github/copilot.vim`. Run `:Copilot setup` if authentication is needed.
- WakaTime is installed through `vim-wakatime`. Run `:WakaTimeApiKey` to configure it.
- `lua/option.lua` disables netrw at startup, but `lua/keymaps.lua` still defines `<leader>pv` with `:Explore`. That mapping may be legacy or require re-enabling netrw if you want to keep using it.
