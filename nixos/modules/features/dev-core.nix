{
  flake.nixosModules.devCore =
    {
      pkgs,
      unstable,
      ...
    }:
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
        valgrind
        libx11
        libxcursor
        libxi
        libxinerama
        libxrandr
        libxrender
        libxshmfence

        # Rust
        rustup

        # Python (default interpreter; keep everything on python3Packages so
        # only ONE Python lives in the closure instead of 3.12 + 3.13)
        pipenv
        python3
        python3Packages.fastapi
        python3Packages.pip
        python3Packages.python-utils
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

        # JVM
        gradle
        jdk
        kotlin
        maven

        # Common development tools
        gh
        jq
        jujutsu
        pre-commit
        prek
        tree-sitter
        ghostty
      ];
    };
}
