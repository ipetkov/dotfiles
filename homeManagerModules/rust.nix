{ config, pkgs, lib, ... }:
let
  inherit (lib.systems);
  system = lib.systems.parse.mkSystemFromString builtins.currentSystem;
  isLinux = lib.systems.inspect.predicates.isLinux system;
in
{
  home.sessionVariables = {
    RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
  };

  home.packages = with pkgs; [
    cargo-outdated
    cargo-update
    clang # Provides `cc` for any *-sys crates
    rust-analyzer
    rustup
  ] ++ lib.lists.optional isLinux pkgs.binutils; # For some reason conflicts on darwin
 }
