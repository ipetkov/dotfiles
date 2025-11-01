{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.fonts;
in
{
  options.dotfiles.fonts.enable = lib.mkEnableOption "fonts";

  config = lib.mkIf cfg.enable {
    xdg.configFile."fontconfig/fonts.conf".source = ../config/fontconfig/fonts.conf;

    fonts.fontconfig.enable = true;

    home.packages = [
      pkgs.font-awesome
      pkgs.hack-font
      pkgs.noto-fonts-color-emoji
    ];
  };
}
