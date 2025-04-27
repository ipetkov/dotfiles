{ config, pkgs, ... }:

let
  gitExtraConfig = config.programs.git.extraConfig;
in
{
  imports = [
    ../../homeManagerModules/common.nix
    ../../homeManagerModules/default.nix
  ];

  nixpkgs.config.allowUnfree = true;

  dotfiles = {
    fonts.enable = true;
    rust.enable = true;
    sway.enable = true;
    taskwarrior.enable = true;
  };

  programs.git = {
    userName = "Ivan Petkov";
    userEmail = "ivanppetkov@gmail.com";
    extraConfig = {
      github.user = "ipetkov";
      commit.gpgsign = true;
      gpg = {
        format = "ssh";
        ssh = {
          program = "/run/current-system/sw/bin/op-ssh-sign";
          allowedSignersFile = builtins.toString (pkgs.writeText "allowedSignersFile" ''
            ivanppetkov@gmail.com namespaces="git" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKFl+lzHHWKk9dgl6XkfSbKCFAkAZEEC3t+WXszgJuXX
          '');
        };
      };
      user.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKFl+lzHHWKk9dgl6XkfSbKCFAkAZEEC3t+WXszgJuXX";
    };
  };

  programs.fish = {
    # NB: don't define greeting in the common module. home-manager will happily concat
    # all function definitions together which is bound to cause havoc...
    functions = {
      fish_greeting = "task";
    };
  };

  programs.jujutsu.settings.signing = {
    key = config.programs.git.extraConfig.user.signingKey;
    behavior = "own";
    backend = "ssh";
    backends.ssh = {
      inherit (gitExtraConfig.gpg.ssh) program;
      allowed-signers = gitExtraConfig.gpg.ssh.allowedSignersFile;
    };
  };

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
