# to make nvim default editor
if [ "$(command -v nvim)" ]; then
    export EDITOR=nvim
fi
# to make kitty default editor
if [ "$(command -v kitty)" ]; then
    export TERM=xterm-kitty
fi

# language specific paths
if [ "$(command -v cargo)" ]; then
    export PATH=$HOME/.cargo/bin:$PATH
fi
if [ "$(command -v flatpak)" ]; then
    export PATH=/var/lib/flatpak/exports/bin:$PATH
fi
if [ "$(command -v go)" ]; then
    export PATH=${PATH}:$(go env GOPATH)/bin
fi

# to make bin in $HOME/my_scripts in the PATH
mkdir -p $HOME/my_scripts
export PATH=$HOME/my_scripts:$PATH
# to make bin in /usr/bin in the PATH
export PATH=/usr/bin:$PATH
# to make bin in $HOME/.local/bin in the PATH
export PATH=$HOME/.local/bin:$PATH
