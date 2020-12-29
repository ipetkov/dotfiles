{ pkgs, ... }:
{
  xdg.configFile."alacritty/alacritty.yml".source = ../config/alacritty/alacritty.yml;

  home.packages = with pkgs; [
    alacritty
  ];
}
