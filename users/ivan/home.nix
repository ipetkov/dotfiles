{ pkgs, ... }:
{
  imports = [
    ../../homeManagerModules/common.nix
    ../../homeManagerModules/fish.nix
    ../../homeManagerModules/fzf.nix
    ../../homeManagerModules/git.nix
    ../../homeManagerModules/nvim.nix
    ../../homeManagerModules/rust.nix
    ../../homeManagerModules/taskwarrior.nix
  ];

  home.packages = with pkgs; [
    firefox
  ];
}
