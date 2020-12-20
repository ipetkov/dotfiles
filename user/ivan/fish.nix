{ config, pkgs, lib, inputs, ... }:
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

    plugins = [
      {
        name = "bass";
        src = inputs.bass;
      }
    ];
  };

  home.packages = [
    pkgs.python3 # Needed by bass
  ];
}
