let
  system = builtins.currentSystem;
  flake = builtins.getFlake (toString ./..);
  lib = flake.inputs.nixpkgs.lib;
  allHomeManagerConfigs = lib.attrsets.mapAttrs
    (_: hmConfig: hmConfig.activationPackage)
    flake.homeManagerConfigurations;
  filteredHomeManagerActivationPackages = lib.attrsets.filterAttrs
    (_: cfg: cfg.system == system)
    allHomeManagerConfigs;
in
  # Return all home-manager configuration derivations matching the current system
  filteredHomeManagerActivationPackages
