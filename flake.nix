{
  description = "ippetkov's nixos configs";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    nixos.url = "nixpkgs/nixos-unstable";

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
      # NB: since we're using homemanager as a nixos module it is NOT
      # necessary to force it's nixpkgs input to follow ours! Its
      # nixos modules accept pkgs by argument, meaning whatever version
      # of nixpkgs we use when calling `lib.nixosSystem` will be used
      # for both nixos and home-manager modules. (but if we use use
      # any other outputs from home-manager, like `hm` or its
      # `lib.homeManagerConfiguration` then that *will* use whatever
      # version the flake picks, which may or may not be the same one
      # as our intput...)
      # 
      # Normally making it follow our input would be no big deal, except
      # currently flake follows inputs are interpreted at the top-most level
      # meaning it doesn't play "well" with nested flakes (i.e. if *another*
      # flake was to use us as an input, nix would search for an input
      # named nixos at *that* flake rather than making our home-manager
      # input use *our* nixos input. clear as mud?)
      #inputs.nixpkgs.follows = "nixos";
    };

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = inputs@{ self, nixos, ... }:
  let
    # NB: use nixos for building our actual system configuration
    # by using the lib from that branch. This branch is gated on
    # desktop tests (e.g. desktop environments passing etc.) which
    # nixpkgs is not gated on. This will also give us better binary
    # cache hits when rebuilding the system, kernel modules, etc.
    #
    # We will still use the nixpkgs branch for home manager and
    # other packages installed through there...
    inherit (nixos) lib legacyPackages;

    myPkgs = self.packages;

    myLib = import ./lib {
      inherit inputs lib myPkgs;
    };

    systemDarwin = "x86_64-darwin";
    systemLinux = "x86_64-linux";

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

    homeManagerConfigurations = import ./homeManagerConfigurations {
      inherit (inputs) home-manager;
      inherit (self) homeManagerModules;

      pkgs = import inputs.nixpkgs {};
    };

    nixosModules = myLib.findNixModules ./nixosModules;

    nixosConfigurations = myLib.findNixosConfigurations {
      system = systemLinux;
      nixosConfigurationsDir = ./nixosConfigurations;
    };

    packages = forAllSystems (system:
      lib.filterAttrs
        (_: pkg: builtins.any (x: x == system) pkg.meta.platforms)
        (import ./pkgs { pkgs = legacyPackages.${system}; })
    );

    apps = forAllSystems (system: {
      # Allow for "pinning" which version of nix-build-uncached is used by the CI
      # (avoids getting rate-limited by the Github API on macOS builders since we can load a
      # particular commit of nixpkgs (which may be in the cache) instead of hitting the repo HEAD
      # every time).
      my-nix-build-uncached = {
        type = "app";
        program = "${legacyPackages.${system}.nix-build-uncached}/bin/nix-build-uncached";
      };
    });
  };
}
