{ pkgs, ... }:
{
  imports = [
    ../../homeManagerModules/common.nix
    ../../homeManagerModules/fish.nix
    ../../homeManagerModules/fonts.nix
    ../../homeManagerModules/fzf.nix
    ../../homeManagerModules/git.nix
    ../../homeManagerModules/nvim.nix
    ../../homeManagerModules/rust.nix
    ../../homeManagerModules/taskwarrior.nix
  ];

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    discord
    firefox
  ];
}
