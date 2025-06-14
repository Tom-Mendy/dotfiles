
def command-exist [command] {
    return ((which $command | length) > 0)
}


if (echo "/usr/local/bin" | path exists) {
    $env.Path = $env.Path | append "/usr/local/bin"
}

# carapace
if ((which carapace | length) > 0) {
    $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional
    mkdir ~/.cache/carapace
    carapace _carapace nushell | save --force ~/.cache/carapace/init.nu
}

alias c = clear

# tmux
$env.Path = $env.Path | append $"($env.HOME)/.local/bin"
alias ts = zsh -c ~/.local/bin/tmux-sessionizer

# language specific paths
if (command-exist cargo) {
  $env.Path = $env.Path |  append ($env.HOME | path join ".cargo/bin")
}
if (command-exist flatpak) {
  $env.Path = $env.Path |  append "/var/lib/flatpak/exports/bin"
}
if (command-exist go) {
  $env.Path = $env.Path |  append ((go env GOPATH) + "/bin")
}
if (command-exist composer) {
  $env.Path = $env.Path |  append (composer global config bin-dir --absolute err> /dev/null)
}

# Android SDK
if (echo ($env.HOME | path join "Android/Sdk/") | path exists) {
  $env.ANDROID_HOME = $env.HOME | path join "Android/Sdk/"
  $env.Path = ($env.Path |  append ($env.ANDROID_HOME | path join "emulator/"))
  $env.Path = ($env.Path |  append ($env.ANDROID_HOME | path join "platform-tools/"))
}

# Bun
if (echo ($env.HOME | path join ".bun/") | path exists) {
  $env.BUN_INSTALL = $env.HOME | path join ".bun/"
  $env.Path = ($env.Path |  append ($env.BUN_INSTALL | path join "bin/"))
}
