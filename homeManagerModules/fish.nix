{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.fish;
in
{
  options.dotfiles.fish.enable = lib.mkOption {
    default = true;
    description = "Whether to enable fish";
    type = lib.types.bool;
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.nix-output-monitor
      pkgs.nix-tree
    ];

    programs = {
      bat.enable = true;
      eza.enable = lib.mkDefault true;
      fish = {
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
          fish_greeting = lib.mkDefault "";
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
    };
  };
}
