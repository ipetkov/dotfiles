{ pkgs, ... }:
{
  xdg.configFile."gtk-3.0/settings.ini".source = ../config/gtk-3.0/settings.ini;
  xdg.configFile."gtk-3.0/import-gsettings.sh".source = ../config/gtk-3.0/import-gsettings.sh;

  home.packages = with pkgs; [
    gtk3 # for managing settings

    hicolor-icon-theme # base icons
    adwaita-icon-theme # standard default theme
    nordic # popular dark theme
  ];
}
