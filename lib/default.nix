# Helper methods and other extensions
{ lib, inputs, myPkgs }:

let
  mkNixosSystem = import ./mkNixosSystem.nix {
    inherit lib myPkgs;
  };

  mkAppendConfig = import ./mkAppendConfig.nix {
    inherit mkNixosSystem;
  };

  mkHost = args: mkAppendConfig ({ inherit inputs; } // args);
in
{
  # Find nixosConfiguration files, which are either nix expressions
  # within the root of the folder, or an expression named `default.nix`
  # which is at most one directory deep.
  findNixosConfigurations = import ./findNixosConfigurations.nix {
    inherit lib mkHost;
  };
}
