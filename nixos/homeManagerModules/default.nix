{
  zsh = import ./shell/zsh.nix;
  neovim = import ./editors/neovim.nix;
  minimal = import ./profiles/minimal.nix;
  full = import ./profiles/full.nix;
}
