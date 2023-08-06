{ lib, myPkgs }:

# Make a new nixosSystem configuration with the provided arguments.
{ system
, inputs
, rootConfig
  # The specific version of nixpkgs we should use for instantiating the system,
  # allowing downstream consumers to change it if necessary.
, nixpkgs ? inputs.nixpkgs
, includeHomeManager ? true
}:

let
  # Allows our flake inputs to appear as an argument in all of our modules.
  specialArgs = {
    inherit inputs;
    myPkgs = myPkgs."${system}";
  };

  homeManagerModule = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    options = {
      # Submodules have merge semantics, making it possible to amend
      # the `home-manager.users` submodule for additional functionality.
      home-manager.users = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submoduleWith {
          # make our flake inputs accessible from home-manager modules as well
          inherit specialArgs;
          modules = [];
        });
      };
    };
    
    config = {
      # Put home-manager results in /etc/profiles instead of ~/.nix-profile
      # keeps a clean $HOME (plus it works with nixos-build-vms)
      home-manager.useUserPackages = true;
    };
  };
in
nixpkgs.lib.nixosSystem {
  inherit system specialArgs;

  modules = [
    ../nixosModules/default.nix
    rootConfig
  ] ++ lib.lists.optional includeHomeManager homeManagerModule;
}
