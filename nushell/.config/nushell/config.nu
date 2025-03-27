
$env.config.show_banner = false

def command-exist [command] {
    return ((which $command | length) > 0)
}

# set default editor
const editor = "nvim"
match  (sys host | get name) {
        "Windows" => {
            $env.config.buffer_editor = "notepad"
            if (command-exist $editor) {
                $env.config.buffer_editor = $editor
            }
        }
        "Ubuntu" => {
            $env.config.buffer_editor = "nano"
            if (command-exist $editor) {
                $env.config.buffer_editor = $editor
            }
        }
        "Darwin" => {
            $env.config.buffer_editor = "nano"
            if (command-exist $editor) {
                $env.config.buffer_editor = $editor
            }
        }
    }

# auto install starship if not installed
# starship is a cross-shell prompt that is fast, customizable and easy to configure
# https://starship.rs/
if (not (command-exist starship)) {
    match (sys host | get name) {
        "Windows" => {
            winget install --id Starship.Starship
        }
        "Ubuntu" => {
            curl -sS https://starship.rs/install.sh | sh
        }
        "NixOS" => {
            curl -sS https://starship.rs/install.sh | sh
        }
        "Darwin" => {
            brew install starship
        }
    }
}

mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

# auto install carapace if not installed
# carapace is a cross-shell auto-completion tool that is fast, customizable and easy to configure
# https://carapace.sh/
if (not (command-exist carapace)) {
    match (sys host | get name) {
        "Windows" => {
            winget install --id rsteube.Carapace
        }
        "Ubuntu" => {
            # todo
            sudo apt-get install carapace
        }
        "NixOS" => {
            nix-env -iA nixos.carapace
        }
        "Darwin" => {
            brew install carapace
        }
    }
}

# completion load nu
source "~/.cache/carapace/init.nu"


# auto install fzf if not installed
if (not (command-exist fzf)) {
    match (sys host | get name) {
        "Windows" => {
            winget install --id junegunn.fzf
        }
        "Ubuntu" => {
            sudo apt install fzf
        }
        "NixOS" => {
            nix-env -iA nixos.fzf
        }
        "Darwin" => {
            brew install fzf
        }
    }
}

mkdir ($nu.data-dir | path join "vendor/plugins")
# alias finder
if (not  (echo ($nu.data-dir | path join "vendor/plugins/alias-finder.nu") | path exists)) {
  http get https://raw.githubusercontent.com/KamilKleina/alias-finder.nu/refs/heads/main/alias-finder.nu | save -f ($nu.data-dir | path join "vendor/plugins/aliases-finder.nu")
}
overlay use ($nu.data-dir | path join "vendor/plugins/aliases-finder.nu")

# git aliases
if (not  (echo ($nu.data-dir | path join "vendor/plugins/git-aliases.nu") | path exists)) {
  http get https://raw.githubusercontent.com/KamilKleina/git-aliases.nu/refs/heads/main/git-aliases.nu | save -f ($nu.data-dir | path join "vendor/plugins/git-aliases.nu")
}
overlay use ($nu.data-dir | path join "vendor/plugins/git-aliases.nu")


