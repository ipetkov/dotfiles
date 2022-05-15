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

    shellAliases = {
      ll = "exa -la";
    };

    plugins = [
      {
        name = "bass";
        src = inputs.bass;
      }
    ];
  };

  programs.bat.enable = true;

  home.packages = with pkgs; [
    python3 # Needed by bass
    exa
  ];
}
