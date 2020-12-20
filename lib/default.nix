# Helper methods and other extensions
{ lib, inputs }:

{
  # Make a new nixosSystem configuration for a host
  mkHost = import ./mkHost.nix {
    inherit lib inputs;
  };
}
