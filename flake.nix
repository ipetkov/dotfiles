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
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay.url = "github:mjlbach/neovim-nightly-overlay";
  };

  outputs = inputs@{ self, nixpkgs, ... }:
  let
    myLib = import ./lib {
      inherit (nixpkgs) lib;
      inherit inputs;
    };

    inherit (myLib) mkHost;
  in
  {
    nixosConfigurations.tartarus = mkHost {
      system = "x86_64-linux";
      rootConfig = ./machine/tartarus;
    };
  };
}
