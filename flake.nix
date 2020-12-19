{
  description = "ippetkov's nixos configs";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      # make sure the same version of nixpkgs is used by home-manager
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }: {
    nixosConfigurations.tartarus = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        (import ./machine/tartarus {
          inherit (home-manager.nixosModules) home-manager;
        })
      ];
    };
  };
}
