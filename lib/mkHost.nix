{ lib, inputs }:

{ rootConfig
, system
, useHomeManager ? true
}:

let
  nixDefaultsModule = { pkgs, ... }: {
    nix = {
      package = pkgs.nixFlakes;
      extraOptions = "experimental-features = nix-command flakes";
      useSandbox = true;

      # Use our inputs as defaults for nixpkgs/nixos so everything
      # moves in lockstep. (Note adding a channel will take precedence over this).
      nixPath = [
        "nixos=${inputs.nixos}"
        "nixpkgs=${inputs.nixpkgs}"
      ];
      registry = {
        nixos.flake = inputs.nixos;
        nixpkgs.flake = inputs.nixpkgs;
      };
    };
  };

  homeManagerModule = lib.attrsets.optionalAttrs useHomeManager {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      # Put home-manager results in /etc/profiles instead of ~/.nix-profile
      # keeps a clean $HOME (plus it works with nixos-build-vms)
      useUserPackages = true;
      # Don't use home-manager's private nixpkgs definition,
      # use the same one as in the rest of the system.
      useGlobalPkgs = true;
    };
  };
in
lib.nixosSystem {
  inherit system;

  # Allows our flake inputs to appear as an argument in all of our modules.
  specialArgs = {
    inherit inputs;
  };

  modules = [
    nixDefaultsModule
    homeManagerModule
    rootConfig
  ];
}
