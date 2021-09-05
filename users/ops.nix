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
}
