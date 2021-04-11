let
  inherit (import ./common.nix) flake;
  inherit (flake.inputs.nixpkgs) lib;
  system = builtins.currentSystem;
  allSystemDefs = lib.attrsets.mapAttrs
    (_: systemConfig: systemConfig.config.system.build.toplevel)
    flake.nixosConfigurations;
  filteredSystemDefs = lib.attrsets.filterAttrs
    (_: cfg: cfg.system == system)
    allSystemDefs;
in
  # Return all system configuration derivations matching the current system
  filteredSystemDefs
