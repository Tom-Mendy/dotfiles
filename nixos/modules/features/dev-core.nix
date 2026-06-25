{
  flake.nixosModules.devCore =
    { pkgs, ... }:
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

        # Python
        pipenv
        python3
        python312Packages.fastapi
        python312Packages.pip
        python312Packages.python-utils
        uv

        # Go
        go

        # Node
        bun
        nodejs_26

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
        jq
        pre-commit
        tree-sitter
      ];
    };
}
