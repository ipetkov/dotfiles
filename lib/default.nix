# Helper methods and other extensions
{ lib, inputs, myPkgs }:

let
  # Make a new nixosSystem configuration for a host
  mkHost = import ./mkHost.nix {
    inherit lib inputs myPkgs;
  };
in
{
  # Find all nix modules at a directory.
  findNixModules = import ./findNixModules.nix {
    inherit lib;
  };

  # Find nixosConfiguration files, which are either nix expressions
  # within the root of the folder, or an expression named `default.nix`
  # which is at most one directory deep.
  findNixosConfigurations = import ./findNixosConfigurations.nix {
    inherit lib mkHost;
  };
}
