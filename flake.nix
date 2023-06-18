{
  description = "ippetkov's nixos configs";

  inputs = {
    # Use the nixos-unstable channel for all of our configurations, even on non-NixOS
    # systems. The nixpkgs-unstable branch tends to break a bit more often than
    # nixos-unstable, so trying this out to see if things are a bit smoother. Also, it is
    # nice having the exact same application versions across all machines rather than
    # mixing and matching branches.
    nixpkgs.url = "nixpkgs/nixos-unstable";
    # Pinned because deploying to rpi is slow as molasses due to SD card I/O being crap
    nixpkgs-for-rpi.url = "github:NixOS/nixpkgs/572d26930456132e7f2035340e3d88b36a5e9b6e";
    # Kernel and firmware were updated to 6.1 in https://github.com/NixOS/nixpkgs/pull/229947
    # but something about the new kernel makes the pibox screen display not work (sitronix driver
    # might be broken?)
    nixpkgs-linux-5-15.url = "github:NixOS/nixpkgs/29339c1529b2c3d650d9cf529d7318ed997c149f";
    # Pinned to before the rpi-kernel version >= 6.1 assertion was added
    nixos-hardware.url = "github:NixOS/nixos-hardware/fb1317948339713afa82a775a8274a91334f6182";

    bass = {
      url = "github:edc/bass";
      flake = false;
    };

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

    systemDarwin = "x86_64-darwin";
    systemLinux = "x86_64-linux";
    systemLinuxArm = "aarch64-linux";

    # The default set of systems for which we want to declare
    # modules/packages/etc.
    defaultSystems = [
      systemDarwin
      systemLinux
    ];

    # Create an attr set for each default system where the key
    # is the system name and the value is the result of the operation
    forAllSystems = f: lib.genAttrs defaultSystems f;
  in
  {
    homeManagerModules = {
      alacritty   = import ./homeManagerModules/alacritty.nix;
      common      = import ./homeManagerModules/common.nix;
      direnv      = import ./homeManagerModules/direnv.nix;
      fish        = args@{ config, lib, pkgs, ... }: (import ./homeManagerModules/fish.nix) (args // { inherit inputs; });
      fonts       = import ./homeManagerModules/fonts.nix;
      fzf         = import ./homeManagerModules/fzf.nix;
      git         = import ./homeManagerModules/git.nix;
      gpg         = import ./homeManagerModules/gpg.nix;
      gtk         = import ./homeManagerModules/gtk.nix;
      nvim        = args@{ config, lib, pkgs, ... }: (import ./homeManagerModules/nvim.nix) (args // { inherit inputs; });
      rust        = import ./homeManagerModules/rust.nix;
      sway        = args@{ config, lib, pkgs, ... }: (import ./homeManagerModules/sway.nix) (args // { inherit myPkgs; });
      taskwarrior = import ./homeManagerModules/taskwarrior.nix;
    };

    homeConfigurations = import ./homeConfigurations {
      inherit (inputs) home-manager nixpkgs;
      inherit (self) homeManagerModules;
    };

    nixosModules = {
      _1password = import ./nixosModules/_1password.nix;
      nixConfig = import ./nixosModules/nixConfig.nix;
      pihole = import ./nixosModules/pihole.nix;
      tailscale = import ./nixosModules/tailscale.nix;
    };

    nixosConfigurations = {
      asphodel = mkHost {
        system = systemLinuxArm;
        rootConfig = ./nixosConfigurations/asphodel;
        includeHomeManager = false;
      };

      rpi = mkHost {
        system = systemLinuxArm;
        rootConfig = ./nixosConfigurations/rpi;
        nixpkgs = inputs.nixpkgs-for-rpi;
        includeHomeManager = false;
      };

      tartarus = mkHost {
        system = systemLinux;
        rootConfig = ./nixosConfigurations/tartarus;
      };
    };

    packages = forAllSystems (system:
    let
      nixpkgs = legacyPackages.${system};
      filter = _: pkg: builtins.any (x: x == system) pkg.meta.platforms;
      allPkgs = import ./pkgs {
        pkgs = nixpkgs;
      };
      systemPkgs = lib.filterAttrs filter allPkgs;
    in
      systemPkgs // { inherit (nixpkgs) nix-build-uncached; }
    );
  };
}
