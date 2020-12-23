{ pkgs, ... }:
{
  imports = [
    ../../nixosModules/hmCommon.nix
    ../../nixosModules/hmFish.nix
    ../../nixosModules/hmFzf.nix
    ../../nixosModules/hmGit.nix
    ../../nixosModules/hmNvim.nix
    ../../nixosModules/hmRust.nix
    ../../nixosModules/hmTaskwarrior.nix
  ];

  home.packages = with pkgs; [
    firefox
  ];
}
