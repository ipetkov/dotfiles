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

    # rustup now carries a rust-analyzer proxy which collides with our direct rust-analyzer install
    (pkgs.runCommand "rustup-no-rust-analyzer-proxy" { } ''
      cp -rs ${rustup} $out
      find $out
      rm -f $out/bin/rust-analyzer
      find $out
    '')
  ] ++ lib.lists.optionals pkgs.stdenv.isLinux (with pkgs; [
    # binutils now conflicts with clang as well, turning this off for now...
    # binutils # For some reason conflicts on darwin
    clang # Provides `cc` for any *-sys crates
  ]);
 }
