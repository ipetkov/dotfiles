{ config, pkgs, lib, ... }:
{
  programs.fish = {
    enable = true;

    # NB: allow nvim to create its own alias/symlink if enabled
    shellInit = "set -x EDITOR vim";

    shellAliases = {
      ll = "exa -la";
    } // lib.attrsets.optionalAttrs config.programs.bat.enable {
      cat = "bat";
    };
  };
}
