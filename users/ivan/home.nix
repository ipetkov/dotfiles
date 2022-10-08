{ pkgs, ... }:
{
  imports = [
    ../../homeManagerModules/alacritty.nix
    ../../homeManagerModules/common.nix
    ../../homeManagerModules/direnv.nix
    ../../homeManagerModules/fish.nix
    ../../homeManagerModules/fonts.nix
    ../../homeManagerModules/fzf.nix
    ../../homeManagerModules/git.nix
    ../../homeManagerModules/gpg.nix
    ../../homeManagerModules/gtk.nix
    ../../homeManagerModules/nvim.nix
    ../../homeManagerModules/rust.nix
    ../../homeManagerModules/sway.nix
    ../../homeManagerModules/taskwarrior.nix
  ];

  nixpkgs.config.allowUnfree = true;

  programs.git = {
    userName = "Ivan Petkov";
    userEmail = "ivanppetkov@gmail.com";
    extraConfig.github.user = "ipetkov";
    signing = {
      # NB: note bang at the end to force that this subkey is used
      # and not direct gpg to use whatever subkey it wants from the
      # parent key (extremely good software...)
      key = "0xBB6F9EFC065832B6!";
      signByDefault = true;
    };
  };

  programs.fish = {
    # NB: don't define greeting in the common module. home-manager will happily concat
    # all function definitions together which is bound to cause havoc...
    functions = {
      fish_greeting = "task";
    };
  };

  programs.neovim.useNightly = true;
  programs.topgrade.enable = true;

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    XDG_CURRENT_DESKTOP = "sway";
  };

  home.packages = with pkgs; [
    blueberry # bluetooth configuration
    discord
    firefox-wayland
    xdg-utils # for xdg-open, make links clickable from outside firefox
  ];
}
