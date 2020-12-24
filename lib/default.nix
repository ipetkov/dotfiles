# Helper methods and other extensions
{ lib, inputs }:

let
  # Make a new nixosSystem configuration for a host
  mkHost = import ./mkHost.nix {
    inherit lib inputs;
  };
  
  # Recursively crawl a directory for any nix modules
  findNixFiles = import ./findNixFiles.nix {
    inherit lib;
  };
in
{
  # Recursively find all nixosModules starting from a root
  # directory, and return an attr set of their flake output name
  # mapped to their expression
  findNixosModules = import ./findNixosModules.nix {
    inherit lib findNixFiles;
  };

  # Find nixosConfiguration files, which are either nix expressions
  # within the root of the folder, or an expression named `default.nix`
  # which is at most one directory deep.
  findNixosConfigurations = import ./findNixosConfigurations.nix {
    inherit lib mkHost;
  };
}
