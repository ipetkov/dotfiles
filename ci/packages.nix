{ system ? builtins.currentSystem }:

let
  inherit (import ./common.nix) flake;
  inherit (flake.inputs.nixpkgs) lib;
in
  # Return all declared packages matching the current system
  lib.attrByPath
    [system]
    {}
    flake.packages
