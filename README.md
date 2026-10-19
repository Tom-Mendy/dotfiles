# dofiles

- install_debian_i3.sh = auto install my debian configuration with i3wm
  this install script take ~ 20 min to complete

- install_fedora.sh = auto install my utily program for fedora

## ⚡ ZSH bootstrap (self-contained)

```bash
git clone https://github.com/Tom-Mendy/dotfiles
cd dotfiles
./install_zsh.sh
```

Ce script :

- détecte l'OS (macOS, Linux, WSL) et installe les dépendances de base (zsh, git, curl, fzf, bat, eza) via apt/dnf/pacman ou Homebrew ;
- installe/outille zinit et zoxide (avec cache local) ;
- génère les complétions zsh (docker, kubectl, bun, gh, ng) ;
- laisse `.zshrc` 100% runtime-only : aucune installation ne bloque l'ouverture d'un shell.

## 🧪 Repro & Perf

- Install sans Nix : `./install_zsh.sh`.
- Benchmark prompt : `./tools/benchmark.sh` (génère `artifacts/zsh-bench.md`). GitHub Actions publie l'artifact sur chaque PR.
- Lint shell : CI exécute `shellcheck` via Nix.
- Cache offline optionnel : placez `cache/zinit.tar.gz` et `cache/zinit.tar.gz.sha256` (sha256sum) pour installer zinit sans réseau.

## NixOS

The NixOS flake is intentionally kept under `nixos/`. The
`zephyrusG14` host selects optional features by importing modules from
`nixos/modules/features/`.

Rebuild the host:

```bash
sudo nixos-rebuild switch --flake ./nixos#zephyrusG14
```

Les mises à jour et les reconstructions sont manuelles. Pour mettre à jour
les dépendances, exécuter `nix flake update --flake ./nixos`, vérifier avec
`nix flake check ./nixos --no-build`, puis reconstruire le système.
Le menu de démarrage conserve au maximum 10 générations.

`workspaceConfiguration` reste disponible dans `nixosModules` comme module
de base pour une autre machine. Il faut lui ajouter une configuration
matérielle avant de l'exposer dans `nixosConfigurations`.

Sur le G14, un scrub Btrfs mensuel vérifie le système de fichiers. Snapper
prend des snapshots horaires de `/home` et conserve 24 horaires, 7 quotidiens,
4 hebdomadaires et 3 mensuels. Ils sont accessibles à root dans
`/home/.snapshots` ; `sudo snapper -c home list` permet de les lister.
Ces snapshots partagent le disque des données et ne remplacent pas une
sauvegarde externe. `/nix` n'est pas inclus dans les snapshots.

Restic sauvegarde `/home/tmendy` chaque jour à partir de 20 h, avec un délai
aléatoire de 30 minutes, dans
`sftp://synology/home/Drive/Backup/zephyrusG14`. Les caches, la corbeille,
les jeux Steam et les dossiers `node_modules` sont exclus. La rétention
conserve 7 sauvegardes quotidiennes, 4 hebdomadaires et 6 mensuelles ;
Restic vérifie les métadonnées du dépôt après chaque sauvegarde.
La clé SSH dédiée, les hôtes connus, la configuration SSH et le mot de passe
Restic restent dans `/var/lib/restic-synology`, accessible uniquement à root.
Le timer ne lance aucune sauvegarde avant la présence du fichier `ready`,
à créer seulement après une initialisation et un essai de restauration.
Conserver également le mot de passe Restic dans un gestionnaire de mots de
passe indépendant du PC. Après configuration, utiliser
`sudo systemctl start restic-backups-synology-home` pour sauvegarder et
`sudo restic-synology-home snapshots` pour lister les sauvegardes.

Le Neovim Nix charge la configuration de `$XDG_CONFIG_HOME/nvim`, ou de
`~/.config/nvim` par défaut. Relier la configuration du dépôt avec
`stow -t "$HOME" nvim` avant la première utilisation. `EDITOR` et `VISUAL`
utilisent le même wrapper que le système. Les répertoires d'outils locaux
du shell sont ajoutés après le PATH existant.

### Développement mobile Android

Créer ensuite un AVD avec une image système disponible :

```bash
sdkmanager --list
avdmanager create avd --name mobile-dev --package "system-images;android-<API>;google_apis;x86_64"
emulator -avd mobile-dev
```

Les projets React Native peuvent ensuite utiliser leur CLI locale avec
`npx react-native`, et les projets Kotlin Android leur wrapper Gradle.

Format or check the nested flake:

```bash
(cd nixos && nix fmt)
nix flake check ./nixos
```

The wrapped Zsh package is portable to any Nix-enabled Dev Container. It does
not load the NixOS, desktop, Neovim, or development-tool modules:

```bash
nix run ./nixos#zsh
```

From another checkout, replace `./nixos` with the path to this repository's
`nixos/` directory.

## Poste Windows DevOps

Ouvre PowerShell et colle cette ligne. Elle télécharge le menu depuis GitHub,
sans cloner le dépôt sur le poste de travail :

```powershell
irm https://raw.githubusercontent.com/Tom-Mendy/dotfiles/main/auto-install-os/install_windows.ps1 | iex
```

Le menu propose une installation de base, une base avec Docker et WSL, un
poste DevOps complet, ou le choix groupe par groupe. Il couvre aussi Java 21,
Maven, Eclipse, Zed et Codex. Les outils classiques passent par `winget`.
Codex passe par l'installeur PowerShell officiel et le script propose ensuite
`codex --login`. Aucun jeu n'est inclus.

## A list of (cool) programs & tools I am currently using

This list is not exhaustive, these are the tools I use on a daily basis and could do without.

### DE

- Window manager : [i3](https://i3wm.org)
- Screen locker : [i3lock-fancy](https://github.com/meskarune/i3lock-fancy)
- Status bar : [i3satus](https://i3wm.org/docs/i3status.html)
- App launcher : [rofi](https://github.com/davatorium/rofi)
- Notification : [dunst](https://github.com/dunst-project/dunst)

### Package manager

- Apt front-end : [nala](https://gitlab.com/volian/nala)
- 🦀: [cargo](https://doc.rust-lang.org/cargo/)

### Term

- Terminal emulator : [kitty](https://sw.kovidgoyal.net/kitty/)
- Shell prompt : [10kpowerline](https://github.com/romkatv/powerlevel10k)
- Shell : [zsh](https://www.zsh.org/)
- Plugin manager : [zinit](https://github.com/zdharma-continuum/zinit)

### Editor

- Editor : [neovim](https://neovim.io/)
- Plugin Manager : [Lazy](https://github.com/folke/lazy.nvim)
  - [nvim-lualine/lualine.nvim](https://github.com/nvim-lualine/lualine)
  - [oknozor/illumination](https://github.com/oknozor/illumination)
  - [scrooloose/nerdtree](https://github.com/scrooloose/nerdtree)
  - [Raimondi/delimitMate](https://github.com/Raimondi/delimitMate)
  - [airblade/vim-gitgutter](https://github.com/airblade/vim-gitgutter)
  - [RRethy/vim-illuminate](https://github.com/RRethy/vim-illuminate)
  - [airblade/vim-rooter](https://github.com/airblade/vim-rooter)
  - [tpope/vim-fugitive](https://github.com/tpope/vim-fugitive)
  - [pearofducks/ansible-vim](https://github.com/pearofducks/ansible-vim)
  - [rust-lang/rust.vim](https://github.com/rust-lang/rust.vim)
  - [aliou/bats.vim](https://github.com/aliou/bats.vim)
  - [hashivim/vim-vagrant](https://github.com/hashivim/vim-vagrant)
  - [chr4/nginx.vim](https://github.com/chr4/nginx.vim)
  - [cespare/vim-toml](https://github.com/cespare/vim-toml)
  - [neoclide/coc.nvim](https://github.com/neoclide/coc.nvim)

**Note :** [here is a cheatsheet](docs/nvim_cheatsheet.md) for the nvim config

### Cli tools

- Grep replacement : [ripgrep](https://github.com/BurntSushi/ripgrep)
- Find replacement : [fd](https://github.com/sharkdp/fd)
- Cat replacement : [bat](https://github.com/sharkdp/bat)
- Hexdump replacement : [hexyl](https://github.com/sharkdp/hexyl)
- du replacement : [dust](https://github.com/bootandy/dust)
- Quick file navigation : [autojump-rs](https://github.com/xen0n/autojump-rs)
- File Explorer : [yazi](https://github.com/sxyazi/yazi)

### Media

- Media library management : [beets](http://beets.io/)
- Music player : [ncmpcpp](https://github.com/arybczak/ncmpcpp)
- Screenshot : [grimshot](https://github.com/swaywm/sway/blob/master/contrib/grimshot)
