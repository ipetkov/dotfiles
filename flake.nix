{
  description = "ippetkov's nixos configs";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations.tartarus = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./machine/tartarus ];
    };
  };
}
