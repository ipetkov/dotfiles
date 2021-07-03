let
  inherit (import ./common.nix) flake;
  inherit (flake.inputs.nixpkgs) lib;

  homeManagerConfigsForSystem = lib.attrByPath
    [builtins.currentSystem]
    {}
    flake.homeManagerConfigurations;

  homeManagerActivationPackages = lib.attrsets.mapAttrs
    (_: hmConfig: hmConfig.activationPackage)
    homeManagerConfigsForSystem;
in
  # Return all home-manager configuration derivations matching the current system
  homeManagerActivationPackages
