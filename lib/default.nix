# Helper methods and other extensions
{
  lib,
  inputs,
  myPkgs,
}:

let
  mkNixosSystem = import ./mkNixosSystem.nix {
    inherit lib myPkgs;
  };

  mkAppendConfig = import ./mkAppendConfig.nix {
    inherit mkNixosSystem;
  };
in
{
  mkHost = args: mkAppendConfig ({ inherit inputs; } // args);
}
