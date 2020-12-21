{ config, pkgs, lib, inputs, ... }:
{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      function fish_greeting
        ${lib.strings.optionalString config.programs.taskwarrior.enable "task"}
      end
    '';

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
