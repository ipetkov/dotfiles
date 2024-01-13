{ pkgs, ... }:
{
  xdg.configFile."alacritty/alacritty.toml".source = ../config/alacritty/alacritty.toml;

  home.packages = with pkgs; [
    alacritty
  ];
}
