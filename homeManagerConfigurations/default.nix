{ pkgs, home-manager, homeManagerModules }:
let
  mkHmConfig = { system, username, homeDirectory, configuration, stateVersion }:
    let
      hmConfig = home-manager.lib.homeManagerConfiguration {
        inherit pkgs system username homeDirectory stateVersion;

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
  mac-mini = mkHmConfig {
    system = "x86_64-darwin";
    username = "ivan";
    homeDirectory = "/Users/ivan";
    configuration = ./mac-mini.nix;
    stateVersion = "21.03";
  };
}
