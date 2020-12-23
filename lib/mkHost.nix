{ lib, inputs }:

{ rootConfig
, system
, useHomeManager ? true
}:

let
  # Allows our flake inputs to appear as an argument in all of our modules.
  specialArgs = {
    inherit inputs;
  };

  homeManagerModule = lib.attrsets.optionalAttrs useHomeManager {
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
lib.nixosSystem {
  inherit system specialArgs;

  modules = [
    ../nixosModules/nix.nix
    homeManagerModule
    rootConfig
  ];
}
