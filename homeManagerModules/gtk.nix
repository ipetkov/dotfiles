{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.gtk;
in
{
  options.dotfiles.gtk.enable = lib.mkEnableOption "gtk";

  config = lib.mkIf cfg.enable {
    xdg.configFile."gtk-3.0/settings.ini".source = ../config/gtk-3.0/settings.ini;
    xdg.configFile."gtk-3.0/import-gsettings.sh".source = ../config/gtk-3.0/import-gsettings.sh;

    home.packages = [
      pkgs.gtk3 # for managing settings

      pkgs.hicolor-icon-theme # base icons
      pkgs.adwaita-icon-theme # standard default theme
      pkgs.nordic # popular dark theme
    ];
  };
}
