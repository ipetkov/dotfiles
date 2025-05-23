{ config, pkgs, ... }:

let
  gitExtraConfig = config.programs.git.extraConfig;
in
{
  dotfiles.fonts.enable = true;

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
          allowedSignersFile = builtins.toString (
            pkgs.writeText "allowedSignersFile" ''
              ivanppetkov@gmail.com namespaces="git" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKFl+lzHHWKk9dgl6XkfSbKCFAkAZEEC3t+WXszgJuXX
            ''
          );
        };
      };
      user.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKFl+lzHHWKk9dgl6XkfSbKCFAkAZEEC3t+WXszgJuXX";
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
}
