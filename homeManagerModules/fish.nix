{ config, pkgs, lib, inputs, ... }:
{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
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

    functions = {
      nom = {
        wraps = "nix";
        body = ''
          if test x_flake_check_x = "x_$argv[1]_$argv[2]_x"
            nix --log-format internal-json -v $argv 2>| command nom --json
          else
            command nom $argv
          end
        '';
      };
    };

    shellAliases = lib.optionalAttrs config.programs.eza.enable {
      ll = "eza -la";
    };
  };

  programs.bat.enable = true;
  programs.eza.enable = lib.mkDefault true;
}
