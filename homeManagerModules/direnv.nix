{ config, lib, ... }:
let
  cfg = config.dotfiles.direnv;
in
{
  options.dotfiles.direnv.enable = lib.mkOption {
    default = true;
    description = "Whether to enable direnv";
    type = lib.types.bool;
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
