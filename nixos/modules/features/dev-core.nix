{ inputs, ... }:
{
  flake.nixosModules.devCore =
    {
      pkgs,
      unstable,
      ...
    }:
    let
      # Not nixpkgs' or the blaze flake's package: see nixos/pkgs/blaze.
      blazePackage = import ../../pkgs/blaze { inherit (inputs) blaze; system = pkgs.stdenv.hostPlatform.system; };
    in
    {
      environment.systemPackages = with pkgs; [
        # C and C++
        cairo
        clang
        clang-tools
        cmake
        criterion
        gcc
        gdb
        gdk-pixbuf
        glib
        glibc
        gnumake
        gtk3
        libxkbcommon
        mesa
        pango
        pkg-config
        libx11
        libxcursor
        libxi
        libxinerama
        libxrandr
        libxrender
        libxshmfence

        # Rust. blaze is its own toolchain; Nix compiles it from source.
        rustup
        blazePackage

        # Python (default interpreter; keep everything on python3Packages so
        # only ONE Python lives in the closure instead of 3.12 + 3.13)
        pipenv
        python3
        uv

        # Go
        go

        # Node
        nodejs_26
        unstable.bun
        typescript

        # Lua
        lua
        lua-language-server
        luajitPackages.jsregexp
        luajitPackages.luarocks

        # Nix
        nixpkgs-fmt

        # Common development tools
        gh
        jq
        jujutsu
        prek
        tree-sitter
        ghostty
      ];
    };
}
