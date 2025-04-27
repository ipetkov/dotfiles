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
    nixpkgs-for-rpi.url = "github:NixOS/nixpkgs/2c8d3f48d33929642c1c12cd243df4cc7d2ce434";
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

  outputs = inputs@{ self, ... }:
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
      homeManagerModules = {
        default = import ./homeManagerModules/default.nix;
        common = import ./homeManagerModules/common.nix;
        fish = args@{ config, lib, pkgs, ... }: (import ./homeManagerModules/fish.nix) (args // { inherit inputs; });
        fonts = import ./homeManagerModules/fonts.nix;
        git = import ./homeManagerModules/git.nix;
        jj = import ./homeManagerModules/jj.nix;
        nvim = args@{ config, lib, pkgs, ... }: (import ./homeManagerModules/nvim.nix) (args // { inherit inputs; });
      };

      homeConfigurations = { };

      nixosModules = {
        _1password = import ./nixosModules/_1password.nix;
        default = import ./nixosModules/default.nix;
        nixConfig = import ./nixosModules/nixConfig.nix;
        pihole = import ./nixosModules/pihole.nix;
        tailscale = import ./nixosModules/tailscale.nix;
        zfs-send = import ./nixosModules/zfs-send.nix;
      };

      nixosConfigurations = {
        asphodel = mkHost {
          system = systemLinuxArm;
          rootConfig = ./nixosConfigurations/asphodel;
        };

        elysium = mkHost {
          system = systemLinux;
          rootConfig = ./nixosConfigurations/elysium;
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
    } // inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = legacyPackages.${system};

        packages = lib.filterAttrs
          (_: pkg: builtins.any (x: x == system) pkg.meta.platforms)
          (import ./pkgs { inherit pkgs; });

        checksForConfigs = configs: extract: lib.attrsets.filterAttrs
          (_: p: p.system == system)
          (lib.attrsets.mapAttrs (_: extract) configs);
      in
      {
        inherit packages;

        checks = lib.lists.foldl
          lib.attrsets.unionOfDisjoint
          packages
          [
            (checksForConfigs self.homeConfigurations (hm: hm.activationPackage))
            (checksForConfigs self.nixosConfigurations (c: c.config.system.build.toplevel))
          ];
      });
}
