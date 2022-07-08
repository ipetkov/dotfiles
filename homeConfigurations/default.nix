{ nixpkgs, home-manager, homeManagerModules }:
let
  mkHmConfig = { system, username, homeDirectory, configuration, stateVersion }: home-manager.lib.homeManagerConfiguration {
    pkgs = import nixpkgs {
      inherit system;
    };

    modules = [
      (import configuration {
        inherit homeManagerModules;
      })
      {
        home = {
          inherit homeDirectory stateVersion username;
        };
      }
    ];
  };
in
{
  mac-mini = mkHmConfig {
    system = "x86_64-darwin";
    username = "ivan";
    homeDirectory = "/Users/ivan";
    configuration = ./mac-mini.nix;
    stateVersion = "21.03";
  };
}
