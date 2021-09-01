{ config, pkgs, ...}:

let
  userName = "ivan";
in
{
  programs.fish.enable = true;

  home-manager.users."${userName}" = import ./home.nix;

  users.users."${userName}" = {
    isNormalUser = true;
    home = "/home/${userName}";
    shell = pkgs.fish;
    extraGroups = [
      "wheel" # Enable sudo
      "disk"
      "audio"
      "video"
      "networkmanager"
      "systemd-journal"
      "libvirtd"
    ];
  };
}
