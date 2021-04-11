let
  inherit (import ./common.nix) flake;
  inherit (flake.inputs.nixpkgs) lib;
  system = builtins.currentSystem;
  allHomeManagerConfigs = lib.attrsets.mapAttrs
    (_: hmConfig: hmConfig.activationPackage)
    flake.homeManagerConfigurations;
  filteredHomeManagerActivationPackages = lib.attrsets.filterAttrs
    (_: cfg: cfg.system == system)
    allHomeManagerConfigs;
in
  # Return all home-manager configuration derivations matching the current system
  filteredHomeManagerActivationPackages
