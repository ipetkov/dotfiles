{ pkgs, pkgs-darwin, home-manager, homeManagerModules }:
let
  mkHmConfig = { system, username, homeDirectory, configuration, stateVersion }:
    let
      hmConfig = home-manager.lib.homeManagerConfiguration {
        inherit system username homeDirectory stateVersion;

        # Currently there is a build issue on darwin, temporarily pinning
        # to a darwin-specific input until it is resolved.
        # See https://github.com/NixOS/nixpkgs/issues/118195
        # See https://github.com/NixOS/nixpkgs/issues/119866
        pkgs = if "x86_64-darwin" == system
          then pkgs-darwin
          else pkgs;

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
