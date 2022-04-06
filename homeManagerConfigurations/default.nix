{ nixpkgs, home-manager, homeManagerModules }:
let
  mkHmConfig = { system, username, homeDirectory, configuration, stateVersion }:
    let
      hmConfig = home-manager.lib.homeManagerConfiguration {
        inherit system username homeDirectory stateVersion;

        pkgs = import nixpkgs {
          inherit system;
        };

        configuration = import configuration {
          inherit homeManagerModules;
        };
      };
    in 
    # Append the original configuration so others can
    # potentially inherit/override it
    hmConfig // { module = configuration; };
in
{
  "x86_64-darwin" = {
    mac-mini = mkHmConfig {
      system = "x86_64-darwin";
      username = "ivan";
      homeDirectory = "/Users/ivan";
      configuration = ./mac-mini.nix;
      stateVersion = "21.03";
    };
  };
}
