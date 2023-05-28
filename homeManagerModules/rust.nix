{ config, pkgs, lib, ... }:
{
  home.sessionVariables = {
    RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
  };

  home.packages = with pkgs; [
    cargo-outdated
    cargo-update
    rust-analyzer
    (runCommand "rustup-no-ra-proxy" { } ''
      mkdir -p $out/bin
      cd $out

      pushd ./bin
      for f in $(find ${pkgs.rustup}/bin -mindepth 1 -not -name 'rust-analyzer'); do
        ln -s "$f"
      done
      popd

      for f in $(find ${pkgs.rustup} -mindepth 1 -maxdepth 1 -not -name 'bin'); do
        ln -s "$f"
      done
    '')
  ] ++ lib.lists.optionals pkgs.stdenv.isLinux (with pkgs; [
    # binutils now conflicts with clang as well, turning this off for now...
    # binutils # For some reason conflicts on darwin
    clang # Provides `cc` for any *-sys crates
  ]);
 }
