{
  description = "ipetkov's nixos configs";

  inputs = {
    # Use the nixos-unstable channel for all of our configurations, even on non-NixOS
    # systems. The nixpkgs-unstable branch tends to break a bit more often than
    # nixos-unstable, so trying this out to see if things are a bit smoother. Also, it is
    # nice having the exact same application versions across all machines rather than
    # mixing and matching branches.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Pinned because deploying to rpi is slow as molasses due to SD card I/O being crap
    nixpkgs-for-rpi.url = "github:NixOS/nixpkgs/cad22e7d996aea55ecab064e84834289143e44a0";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    nixos-pibox = {
      url = "github:ipetkov/nixos-pibox";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  nixConfig.extra-substituters = [
    "https://ipetkov.cachix.org"
  ];

  outputs =
    inputs@{ self, ... }:
    let
      inherit (inputs.nixpkgs) lib legacyPackages;

      myPkgs = self.packages;

      myLib = import ./lib {
        inherit inputs lib myPkgs;
      };

      inherit (myLib) mkHost;

      systemLinux = "x86_64-linux";
      systemLinuxArm = "aarch64-linux";
    in
    {
      homeManagerModules.default = import ./homeManagerModules/default.nix;

      homeConfigurations = { };

      nixosModules.default = import ./nixosModules/default.nix;

      nixosConfigurations = {
        asphodel = mkHost {
          system = systemLinuxArm;
          rootConfig = ./nixosConfigurations/asphodel;
        };

        elysium = mkHost {
          system = systemLinux;
          rootConfig = ./nixosConfigurations/elysium;
        };

        erebus = mkHost {
          system = systemLinux;
          rootConfig = ./nixosConfigurations/erebus;
          includeHomeManager = true;
        };

        rpi = mkHost {
          system = systemLinuxArm;
          rootConfig = ./nixosConfigurations/rpi;
          nixpkgs = inputs.nixpkgs-for-rpi;
        };

        tartarus = mkHost {
          system = systemLinux;
          rootConfig = ./nixosConfigurations/tartarus;
          includeHomeManager = true;
        };
      };
    }
    // inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = legacyPackages.${system};

        packages = lib.filterAttrs (_: pkg: builtins.any (x: x == system) pkg.meta.platforms) (
          import ./pkgs { inherit pkgs; }
        );

        checksForConfigs =
          configs: extract:
          lib.attrsets.filterAttrs (_: p: p.system == system) (lib.attrsets.mapAttrs (_: extract) configs);

        formatter = pkgs.nixfmt-tree;
      in
      {
        inherit formatter packages;

        checks = lib.lists.foldl lib.attrsets.unionOfDisjoint packages [
          (checksForConfigs self.homeConfigurations (hm: hm.activationPackage))
          (checksForConfigs self.nixosConfigurations (c: c.config.system.build.toplevel))
        ];

        devShells = {
          default = pkgs.mkShell {
            packages = [
              formatter
            ];
          };
          ci = pkgs.mkShell {
            packages = [
              pkgs.nix-fast-build
            ];
          };
        };
      }
    );
}
