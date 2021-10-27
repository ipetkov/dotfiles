{ system ? builtins.currentSystem }:

let
  inherit (import ./common.nix) flake;
in
  # Return all declared packages matching the current system
  flake.packages.${system}
