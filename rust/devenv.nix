{
  toolchain,
  inputs,
  pkgs,
  ...
}:
 inputs.devenv.lib.mkShell {
  inherit inputs pkgs;
  packages = [ toolchain ] ++ (with pkgs; [
    cargo-watch # auto-rebuild saat file berubah
    cargo-edit # cargo add/rm/upgrade
    cargo-deny # audit depedency
    pkg-config
    openssl
  ]);

  # Tambahkan ini agar rust-analyzer bisa resolve stdlib
  env.RUST_SRC_PATH = "${toolchain}/lib/rustlib/src/rust/library";

  enterShell = ''
    echo "🦀 Rust Dev Shell (${pkgs.stdenv.hostPlatform.system})"
    echo ""
    echo "Opsional: Memastikan PKG_CONFIG melihat openssl dari Nix"
    echo "export PKG_CONFIG_PATH='${pkgs.openssl.dev}/lib/pkgconfig'"
    echo ""
    rustc --version
    cargo --version
  '';
}
