let
  inherit (import ./common.nix) flake;
  system = builtins.currentSystem;
in
  # Return all declared packages matching the current system
  flake.packages.${system}
