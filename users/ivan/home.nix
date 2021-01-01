{ pkgs, ... }:
{
  imports = [
    ../../homeManagerModules/alacritty.nix
    ../../homeManagerModules/common.nix
    ../../homeManagerModules/fish.nix
    ../../homeManagerModules/fonts.nix
    ../../homeManagerModules/fzf.nix
    ../../homeManagerModules/git.nix
    ../../homeManagerModules/nvim.nix
    ../../homeManagerModules/rust.nix
    ../../homeManagerModules/sway.nix
    ../../homeManagerModules/taskwarrior.nix
  ];

  nixpkgs.config.allowUnfree = true;

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    XDG_CURRENT_DESKTOP = "sway";
  };

  home.packages = with pkgs; [
    discord
    firefox-wayland
  ];
}
