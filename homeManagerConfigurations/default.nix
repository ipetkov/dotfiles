{ inputs, legacyPackages, homeManagerModules }:
let
  mkHmConfig = { system, username, homeDirectory, configuration }:
    let
      hmConfig = inputs.home-manager.lib.homeManagerConfiguration {
        inherit system username homeDirectory;
        pkgs = legacyPackages.${system};
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
  };
}
