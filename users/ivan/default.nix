{ lib, pkgs, ... }:

let
  userName = "ivan";
in
{
  programs.fish.enable = true;

  users.users."${userName}" = {
    uid = lib.mkForce 1000;
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
