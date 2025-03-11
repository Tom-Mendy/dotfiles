
if (echo "/usr/local/bin" | path exists) {
    $env.Path = ($env.Path | prepend "/usr/local/bin")
}

# carapace
if ((which carapace | length) > 0) {
    $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional
    mkdir ~/.cache/carapace
    carapace _carapace nushell | save --force ~/.cache/carapace/init.nu
}


