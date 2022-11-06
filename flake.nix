{
  description = "ippetkov's nixos configs";

  inputs = {
    # Use the nixos-unstable channel for all of our configurations, even on non-NixOS
    # systems. The nixpkgs-unstable branch tends to break a bit more often than
    # nixos-unstable, so trying this out to see if things are a bit smoother. Also, it is
    # nice having the exact same application versions across all machines rather than
    # mixing and matching branches.
    nixpkgs.url = "nixpkgs/nixos-unstable";

    nixos-stable.url = "nixpkgs/nixos-22.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # For pinning our SD image installer to a known good commit.
    # Feel free to bump this to a newer commit if things still seem to keep working!
    nixpkgs-sd-image.url = "nixpkgs/34ad3ffe08adfca17fcb4e4a47bb5f3b113687be";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    bass = {
      url = "github:edc/bass";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.flake-compat.follows = "flake-compat";
      inputs.nixpkgs.follows = "nixpkgs";
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
      nixConfig = import ./nixosModules/nixConfig.nix;
      pihole = import ./nixosModules/pihole.nix;
      tailscale = import ./nixosModules/tailscale.nix;
    };

    nixosConfigurations = {
      asphodel = mkHost {
        system = systemLinuxArm;
        nixpkgs = inputs.nixos-stable;
        rootConfig = ./nixosConfigurations/asphodel;
        includeHomeManager = false;
      };

      rpi = mkHost {
        system = systemLinuxArm;
        rootConfig = ./nixosConfigurations/rpi;
        nixpkgs = inputs.nixos-stable;
        includeHomeManager = false;
      };

      tartarus = mkHost {
        system = systemLinux;
        rootConfig = ./nixosConfigurations/tartarus;
      };
    };

    sdImages = lib.mapAttrs
      (_: cfg: (cfg.appendConfig {
        nixpkgs = inputs.nixpkgs-sd-image;
        rootConfig = ./nixosModules/sd-image.nix;
      }).config.system.build.sdImage)
      {
        inherit (self.nixosConfigurations) rpi;
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
