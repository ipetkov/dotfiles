{ pkgs, ... }:
{
  xdg.configFile."fontconfig/fonts.conf".source = ../config/fontconfig/fonts.conf;

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    noto-fonts-emoji
  ];
}

