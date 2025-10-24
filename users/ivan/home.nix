{ config, pkgs, ... }:

let
  gitSettings = config.programs.git.settings;
in
{
  dotfiles.fonts.enable = true;

  programs.git = {
    settings = {
      commit.gpgsign = true;
      github.user = "ipetkov";
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
      user = {
        name = "Ivan Petkov";
        email = "ivanppetkov@gmail.com";
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKFl+lzHHWKk9dgl6XkfSbKCFAkAZEEC3t+WXszgJuXX";
      };
    };
  };

  programs.jujutsu.settings.signing = {
    key = gitSettings.user.signingKey;
    behavior = "own";
    backend = "ssh";
    backends.ssh = {
      inherit (gitSettings.gpg.ssh) program;
      allowed-signers = gitSettings.gpg.ssh.allowedSignersFile;
    };
  };
}
