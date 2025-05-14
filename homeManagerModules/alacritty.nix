{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.alacritty;
in
{
  options.dotfiles.alacritty = {
    enable = lib.mkEnableOption "alacritty";
    package = lib.mkPackageOption pkgs "alacritty" { };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."alacritty/alacritty.toml".source = ../config/alacritty/alacritty.toml;

    home.packages = [
      cfg.package
    ];
  };
}
