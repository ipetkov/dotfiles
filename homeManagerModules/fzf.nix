{ config, lib, pkgs, ... }:
let
  cfg = config.dotfiles.fzf;
in
{
  options.dotfiles.fzf.enable = lib.mkOption {
    default = true;
    description = "Whether to enable fzf";
    type = lib.types.bool;
  };

  config = lib.mkIf cfg.enable {
    programs.fzf = {
      enable = true;
      defaultCommand = "rg --files --hidden --glob !.git";
      fileWidgetCommand = "rg --files --hidden --glob !.git";
      changeDirWidgetCommand = "fd --type d";
    };

    home.packages = [
      # Ensure we include ripgrep and fd for the commands above
      pkgs.ripgrep
      pkgs.fd
    ];
  };
}
