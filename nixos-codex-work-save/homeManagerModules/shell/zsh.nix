{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      e = "nvim";
      ls = "eza";
      la = "eza -a";
      ll = "eza -lah";
      k = "kubectl";
      cat = "bat --style=plain";
    };

    initContent = ''
      export TERM="''${TERM:-xterm-256color}"
      export EDITOR=nvim
      export HISTFILE=$HOME/.zsh_history
      export HISTSIZE=10000
      export SAVEHIST=10000
      setopt INC_APPEND_HISTORY SHARE_HISTORY

      export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
      eval "$(zoxide init zsh --cmd cd)"

      bindkey '^[[1;5D' backward-word
      bindkey '^[[1;5C' forward-word
      bindkey '^[[H' beginning-of-line
      bindkey '^[[F' end-of-line
    '';
  };

  home.packages = with pkgs; [ zoxide fzf eza bat ];
}
