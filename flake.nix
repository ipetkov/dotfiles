{
  description = "ipetkov's nixos configs";

  inputs = {
    # Use the nixos-unstable channel for all of our configurations, even on non-NixOS
    # systems. The nixpkgs-unstable branch tends to break a bit more often than
    # nixos-unstable, so trying this out to see if things are a bit smoother. Also, it is
    # nice having the exact same application versions across all machines rather than
    # mixing and matching branches.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
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

      eachSystem =
        systems: f:
        let
          # Merge together the outputs for all systems.
          op =
            attrs: system:
            let
              ret = f system;
              op =
                attrs: key:
                attrs
                // {
                  ${key} = (attrs.${key} or { }) // {
                    ${system} = ret.${key};
                  };
                };
            in
            builtins.foldl' op attrs (builtins.attrNames ret);
        in
        builtins.foldl' op { } systems;

      eachDefaultSystem = eachSystem [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    {
      inherit myLib;

      homeManagerModules.default = import ./homeManagerModules/default.nix;

      homeConfigurations = { };

      nixosModules.default = import ./nixosModules/default.nix;

      nixosConfigurations = {
        tartarus = mkHost {
          inherit (inputs) nixpkgs;
          system = "x86_64-linux";
          rootConfig = ./nixosConfigurations/tartarus;
          includeHomeManager = true;
        };
      };
    }
    // eachDefaultSystem (
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
              pkgs.zizmor
            ];
          };
          ci = pkgs.mkShell {
            packages = [
              pkgs.nix-fast-build
            ];
          };
          zizmor = pkgs.mkShell {
            packages = [
              pkgs.zizmor
            ];
          };
        };
      }
    );
}
