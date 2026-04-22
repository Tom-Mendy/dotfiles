{
  inputs,
  ...
}@args:
let
  promptModule =
    {
      config,
      lib,
      pkgs,
      wlib,
      ...
    }:
    let
      zdotdir = if config.dynamicMode then config.dynamicZdotdirPath else config.zdotdirPath;
    in
    {
      options = {
        dynamicMode = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Use an impure zsh config directory for fast local edits.
          '';
        };

        zdotdirPath = lib.mkOption {
          type = wlib.types.stringable;
          default = inputs.zsh-config.outPath;
        };

        dynamicZdotdirPath = lib.mkOption {
          type = wlib.types.stringable;
          default = "~/dotfiles/zsh";
        };
      };

      config.zshrc.content = lib.mkBefore ''
        _load_powerlevel10k_prompt() {
          [[ -t 1 ]] || return

          source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
          [[ -f ${zdotdir}/.p10k.zsh ]] && source ${zdotdir}/.p10k.zsh
        }

        if [[ -t 1 && -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '';
    };
in
if args.asWrapperModule or false then promptModule else { }
