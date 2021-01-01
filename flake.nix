{
  description = "ippetkov's nixos configs";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    nixos.url = "nixpkgs/nixos-unstable";

    bass = {
      url = "github:edc/bass";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      # make sure the same version of nixpkgs is used by home-manager
      # in this case we'll track the nixos branch since that's the
      # one we use for generating our actual machine configs
      inputs.nixpkgs.follows = "nixos";
    };

    neovim-nightly-overlay.url = "github:mjlbach/neovim-nightly-overlay";
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
    inherit (nixos) lib;
    myLib = import ./lib {
      inherit inputs lib;
    };
  in
  {
    homeManagerModules = myLib.findNixModules ./homeManagerModules;

    nixosModules = myLib.findNixModules ./nixosModules;

    nixosConfigurations = myLib.findNixosConfigurations {
      system = "x86_64-linux";
      nixosConfigurationsDir = ./nixosConfigurations;
    };
  };
}
