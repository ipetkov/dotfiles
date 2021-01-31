{ config, pkgs, ... }:
{
  home.sessionVariables = {
    RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
  };

  home.packages = with pkgs; [
    binutils
    cargo-outdated
    cargo-update
    clang # Provides `cc` for any *-sys crates
    rust-analyzer
    rustup
  ];
 }
