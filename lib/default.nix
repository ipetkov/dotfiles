# Helper methods and other extensions
{ lib, inputs }:

rec {
  # Make a new nixosSystem configuration for a host
  mkHost = import ./mkHost.nix {
    inherit lib inputs;
  };

  # Recursively crawl a directory for any nix modules
  findNixFiles = import ./findNixFiles.nix {
    inherit lib;
  };

  # Recursively find all nixosModules starting from a root
  # directory, and return an attr set of their flake output name
  # mapped to their expression
  findNixosModules = import ./findNixosModules.nix {
    inherit lib findNixFiles;
  };
}
