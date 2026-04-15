# tmux + Neovim workflow

Objectif: utiliser tmux comme orchestrateur, Neovim comme editeur.

## Regle simple

- Ecrire code: Neovim
- Lancer service, logs, db, kubectl: tmux

## Raccourcis importants

- `Ctrl-f` dans shell: ouvre picker `sesh`
- `prefix + f` dans tmux: ouvre picker `sesh`
- `Ctrl-h/j/k/l`: navigation pane tmux et split Neovim sans changer habitude

## Session type (backend)

- window 1: `nvim`
- window 2: `npm run dev` ou `go run ./...`
- window 3: `docker compose up` ou logs
- window 4: `git`/ops (`kubectl`, `k9s`, `psql`)

## sesh

Config: `~/.config/sesh/sesh.toml`

- `dotfiles` session dediee
- wildcard auto pour `~/projects/*`, `~/work/*`, `~/tests/*`
- startup par defaut: `nvim`

## Migration 7 jours

1. Jour 1-2: garder splits Neovim pour lecture/refactor, lancer services dans tmux.
2. Jour 3-4: utiliser picker `sesh` pour chaque changement de projet.
3. Jour 5-7: interdire terminal Neovim pour long-running tasks.

Si friction persiste, ajuster d'abord keybinds, pas plugins.
