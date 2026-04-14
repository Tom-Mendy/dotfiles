# Zsh configuration

This document reflects the current zsh setup in this repository, based on [`zsh/.zshrc`](/home/tmendy/dotfiles/zsh/.zshrc) and [`zsh/.p10k.zsh`](/home/tmendy/dotfiles/zsh/.p10k.zsh).

## Bootstrap

The shell config is runtime-only. It does not install anything on shell startup.

Bootstrap is handled by [`install_zsh.sh`](/home/tmendy/dotfiles/install_zsh.sh), which:

- installs base packages and `stow`
- installs `zinit`, `zoxide`, and `atuin`
- generates shell completions
- stows the `zsh/` directory into `$HOME`

If `~/.zinit/bin/zinit.zsh` is missing, `.zshrc` prints a bootstrap message and returns early.

## Prompt and plugin manager

Plugin management is handled by `zinit`.

Loaded plugins/snippets:

- `zdharma-continuum/fast-syntax-highlighting`
- `zsh-users/zsh-autosuggestions`
- `zsh-users/zsh-completions`
- `Aloxaf/fzf-tab`
- `junegunn/fzf`
- `MichaelAquilina/zsh-you-should-use`
- `OMZP::git`
- `romkatv/powerlevel10k`

The prompt uses Powerlevel10k with instant prompt enabled. The checked-in prompt config is the generated wizard config in [`zsh/.p10k.zsh`](/home/tmendy/dotfiles/zsh/.p10k.zsh).

Current prompt layout:

- left prompt: current directory, git status, newline, prompt character
- right prompt: exit status, command duration, jobs, direnv, language/runtime managers, Kubernetes/AWS/GCloud context, user/host, todo/task indicators, time

## Completion and fuzzy selection

Completion cache lives under `${XDG_CACHE_HOME:-$HOME/.cache}/zsh`.

Behavior currently configured:

- `compinit` is delegated to `zinit` helpers
- local completion files are loaded from `$ZSH_CACHE_DIR/completions`
- the completion dump is rebuilt if local completion files are newer than the cache
- `fzf-tab` is enabled for completion menus
- `FZF_DEFAULT_OPTS` sets a bordered reverse layout with 40% height
- previews use `bat` by default
- extra previews are configured for `cd`, `zoxide`, `docker`, and `kubectl`

## Navigation and environment

Navigation:

- `zoxide` replaces `cd` when installed: `zoxide init zsh --cmd cd`
- `chpwd()` runs `eza --tree -L 1`, so changing directories shows a shallow tree view

Environment and PATH handling:

- `TERM` falls back to `xterm-256color` if unset
- `EDITOR=nvim` when `nvim` exists
- `path` is deduplicated with `typeset -U path PATH`
- prepends common user/tool paths such as `~/.local/bin`, `~/.atuin/bin`, `~/.cargo/bin`, `~/.bun/bin`, `~/.opencode/bin`, `/opt/nvim-linux-x86_64/bin`
- appends optional paths for Flatpak, Go, Composer, and Android SDK
- exports `BUN_INSTALL` when `~/.bun` exists

Optional tool hooks:

- `direnv`
- `atuin`
- `ghcup`
- Bun shell support from `~/.bun/_bun`

History is configured with:

- `HISTFILE=~/.zsh_history`
- `HISTSIZE=10000`
- `SAVEHIST=10000`
- `INC_APPEND_HISTORY`
- `SHARE_HISTORY`

Atuin is configured with:

- `ATUIN_FILTER_MODE=global`
- `ATUIN_SEARCH_MODE=fuzzy`
- `ATUIN_STYLE=compact`
- `ATUIN_SYNC_ADDRESS=https://atuin.home.tom-mendy.com`

## Aliases and bindings

General aliases:

- `e=$EDITOR`
- `grep='grep --color=auto'`
- `gitlog=...` for blame-based author stats
- `proxy`, `unproxy`, `proxy_http`

Conditional aliases:

- `bat`/`cat` use `bat` or `batcat`
- `ls`, `la`, `ll`, `tree` use `eza`
- `k=kubectl`
- `rm=safe-rm`

Keybindings:

- `Ctrl-F` inserts `tmux-sessionizer`
- `Ctrl-Left` / `Ctrl-Right` move by word
- `Alt-B` / `Alt-F` move by word
- `Home` / `End` jump to line boundaries
- `Ctrl-Delete` and `Ctrl-Backspace` delete by word

Bindings are applied to both `emacs` and `viins` keymaps.

## Current caveats

These are true in the current config and worth knowing:

- `chpwd()` calls `eza` unconditionally, so directory changes will error if `eza` is not installed
- `~/.bun/_bun` is sourced twice: once conditionally in the optional tools section and once again at the end of the file
- `ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE` is set twice; the later value (`fg=6`) wins
