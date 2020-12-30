{ pkgs, ... }:
{
  xdg.configFile."fontconfig/fonts.conf".source = ../config/fontconfig/fonts.conf;

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    font-awesome
    noto-fonts-emoji
  ];
}

