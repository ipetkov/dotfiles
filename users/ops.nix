{ config, pkgs, ...}:

let
  userName = "ops";
in
{
  programs.fish.enable = true;

  users.users."${userName}" = {
    isNormalUser = true;
    home = "/home/${userName}";
    shell = pkgs.fish;
  };

  home-manager.users."${userName}" = {
    home.stateVersion = "21.03";

    imports = [
      ../homeManagerModules/direnv.nix
    ];

    programs.fish = {
      shellAliases = {
        ll = "ls -la";
      };
    };
  };
}
