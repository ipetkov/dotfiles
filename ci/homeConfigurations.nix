{ system ? builtins.currentSystem }:

let
  inherit (import ./common.nix) flake;
  inherit (flake.inputs.nixpkgs) lib;

  homeConfigActivationPackages = lib.attrsets.mapAttrs
    (_: hmConfig: hmConfig.activationPackage)
    flake.homeConfigurations;

  filteredHomeConfigActivationPackages = lib.attrsets.filterAttrs
    (_: activationPackage: activationPackage.system == system)
    homeConfigActivationPackages;
in
  # Return all home-manager configuration derivations matching the current system
  filteredHomeConfigActivationPackages
