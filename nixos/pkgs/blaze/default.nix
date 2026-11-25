# blaze is not in nixpkgs, and the package its own flake exposes cannot build
# at the pinned revision: `flake.nix` runs `.github/scripts/build_release.py`,
# which the tree does not carry. Build it the way the repository's CI does
# instead: build `toolchain_cut`, cut the pinned toolchain shelf out of the
# tree, then build `blaze` and `blaze-fact-shim` against that shelf.
#
# Nix builds blaze from source, so it reports itself as `0.0.0` (dev build).
# The first run copies the shelf into `~/.blaze/v2/toolchain`, where this
# version of blaze looks for its standard library and sysroot.
#
# x86-64 Linux patch: the dev engine's interim table of std's build-script cfg
# lists only the two aarch64 triples, so it refuses every program on this
# machine before compiling it. The script prints `backtrace_in_libstd` for
# every target, so the row added by the patch says exactly that.
{ blaze, system ? "x86_64-linux" }:
let
  pkgs = import blaze.inputs.nixpkgs {
    inherit system;
    overlays = [ blaze.inputs.rust-overlay.overlays.default ];
  };
  inherit (pkgs) lib;

  pin = lib.removePrefix "nightly-" (lib.fileContents "${blaze}/pins/toolchain");
  rust = pkgs.rust-bin.nightly.${pin}.default;
  rustPlatform = pkgs.makeRustPlatform { cargo = rust; rustc = rust; };

  target = {
    x86_64-linux = "x86_64-unknown-linux-gnu";
    aarch64-linux = "aarch64-unknown-linux-gnu";
  }.${system} or (throw "blaze: no toolchain target known for ${system}");

  lock = builtins.fromTOML (builtins.readFile "${blaze}/Cargo.lock");
  # Every crates.io package in the lock, as the `.crate` archive `toolchain_cut`
  # reads from its registry folder. Only the ones beneath bstd are packed, but
  # which those are depends on target and features, so make them all available.
  registryCrates = map (p: {
    file = "${p.name}-${p.version}.crate";
    drv = pkgs.fetchurl {
      name = "${p.name}-${p.version}.crate";
      url = "https://static.crates.io/crates/${p.name}/${p.name}-${p.version}.crate";
      sha256 = p.checksum;
    };
  }) (builtins.filter
    (p: (p.source or "") == "registry+https://github.com/rust-lang/crates.io-index" && p ? checksum)
    lock.package);
in
rustPlatform.buildRustPackage {
  pname = "blaze";
  version = (builtins.fromTOML (builtins.readFile "${blaze}/Cargo.toml")).workspace.package.version;
  src = blaze;
  cargoLock.lockFile = "${blaze}/Cargo.lock";
  patches = [ ./x86_64-std-script-cfg.patch ];

  buildPhase = ''
    runHook preBuild

    cargo build --offline --release -p scripts --bin toolchain_cut -j "$NIX_BUILD_CORES"

    mkdir -p "$TMPDIR/reg" "$TMPDIR/shelf"
    ${lib.concatMapStringsSep "\n" (c: ''ln -s ${c.drv} "$TMPDIR/reg/${c.file}"'') registryCrates}
    ./target/release/toolchain_cut \
      "{\"tree\": \"$PWD\", \"targets\": [\"${target}\"], \"registry\": \"$TMPDIR/reg\", \"shelf\": \"$TMPDIR/shelf\", \"write_pin\": true, \"check\": false, \"macro_side\": true}"

    cargo build --offline --release -p blaze-cli --bins -j "$NIX_BUILD_CORES"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/libexec/blaze" "$out/share/blaze/v2/toolchain" "$out/bin"
    cp ./target/release/blaze "$out/libexec/blaze/blaze"
    cp ./target/release/blaze-fact-shim "$out/libexec/blaze/blaze-fact-shim"
    cp -r "$TMPDIR/shelf"/* "$out/share/blaze/v2/toolchain/"

    pinned="$(tr -d '[:space:]' < crates/blaze-toolchain/PINNED)"
    install -m 0755 ${./wrapper.sh} "$out/bin/blaze"
    substituteInPlace "$out/bin/blaze" \
      --subst-var-by shelf "$out/share/blaze/v2/toolchain" \
      --subst-var-by real "$out/libexec/blaze/blaze" \
      --subst-var-by pinned "$pinned"

    runHook postInstall
  '';

  doCheck = false;
  auditable = false;

  meta = {
    description = "cargo build, test and run from a daemon that keeps your workspace compiled";
    homepage = "https://ix.dev/blaze";
    license = with lib.licenses; [ mit asl20 ];
    mainProgram = "blaze";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}
