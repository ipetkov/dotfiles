{ config, pkgs, lib, inputs, ... }:
{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      function fish_greeting
        ${lib.strings.optionalString config.programs.taskwarrior.enable "task"}
      end
    '';

    promptInit = ''
      if test -n "$IN_NIX_SHELL"
        set --global nix_shell_info "<nix-shell> "
      else
        set --global nix_shell_info ""
      end

      functions --copy fish_prompt fish_prompt_default
      function fish_prompt
        echo -n -s "$nix_shell_info"
        fish_prompt_default
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
