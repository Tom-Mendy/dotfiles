
const editor = "nvim"

def command-exist [command] {
    return ((which $command | length) > 0)
}

# set default editor
match  (sys host | get name) {
        "Windows" => {
            $env.config.buffer_editor = "notepad"
            if (not (command-exist $editor)) {
                $env.config.buffer_editor = $editor
            }
        }
        "Linux" => {
            $env.config.buffer_editor = "nano"
            if (not (command-exist $editor)) {
                $env.config.buffer_editor = $editor
            }
        }
        "Darwin" => {
            $env.config.buffer_editor = "nano"
            if (not (command-exist $editor)) {
                $env.config.buffer_editor = $editor
            }
        }
    }

# auto install starship if not installed
# starship is a cross-shell prompt that is fast, customizable and easy to configure
# https://starship.rs/
if not (command-exist starship) {
    match (sys host | get name) {
        "Windows" => {
            winget install --id Starship.Starship
        }
        "Linux" => {
            curl -sS https://starship.rs/install.sh | sh
        }
        "Darwin" => {
            brew install starship
        }
    }
}

# auto install carapace if not installed
# carapace is a cross-shell auto-completion tool that is fast, customizable and easy to configure
# https://carapace.sh/
if not (command-exist carapace) {
    match (sys host | get name) {
        "Windows" => {
            winget install --id rsteube.Carapace
        }
        "Linux" => {
            sudo apt-get install starship
        }
        "Darwin" => {
            brew install starship
        }
    }
}

mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

# completion load nu
source ~/.cache/carapace/init.nu

