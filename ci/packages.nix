let
  system = builtins.currentSystem;
  flake = builtins.getFlake (toString ./..);
in
  # Return all declared packages matching the current system
  flake.packages.${system}
