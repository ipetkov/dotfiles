{ pkgs, ... }:
{
  programs.fish = {
    enable = true;

    # NB: allow nvim to create its own alias/symlink if enabled
    shellInit = "set -x EDITOR vim";

    shellAliases = {
      cat = "bat";
      ll = "exa -la";
    };
  };
}
