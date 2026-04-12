# nvim

## Architecture

This config now uses LazyVim as a dependency through lazy.nvim.

- Base: LazyVim plugin (`LazyVim/LazyVim`)
- Custom layer: files in `lua/plugins/`
- Source of truth: this repo

This means you should not update the setup by pulling a LazyVim starter repo. Updates are managed by lazy.nvim.

## Updates

### Update plugins and LazyVim

```vim
:Lazy update
```

### Review available updates

```vim
:Lazy check
```

### Rollback strategy

1. Keep `lazy-lock.json` committed.
2. If an update breaks behavior, restore the previous `lazy-lock.json` from git.
3. Restart Neovim and run:

```vim
:Lazy restore
```

## Setup Copilot

1. Install the Copilot plugin

```vim
:Copilot setup
```

## WakaTime

[Web](https://wakatime.com/neovim)

1. Set your WakaTime API key

```vim
:WakaTimeApiKey
```
