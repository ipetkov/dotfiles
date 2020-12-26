{ pkgs, ... }:
{
  programs.alacritty = {
    enable = true;

    settings = {
      # remedy_dark theme
      # https://github.com/eendroroy/alacritty-theme/blob/master/themes/remedy_dark.yaml
      colors = {
        # Default colors
        primary = {
          background = "0x2c2b2a";
          foreground = "0xf9e7c4";

          dim_foreground    = "0x685E4A";
          bright_foreground = "0x1C1508";
          dim_background    = "0x202322";
          bright_background = "0x353433";
        };

        # Cursor colors
        cursor = {
          text   = "0xf9e7c4";
          cursor = "0xf9e7c4";
        };

        # Normal colors
        normal = {
          black   = "0x282a2e";
          blue    = "0x5f819d";
          cyan    = "0x5e8d87";
          green   = "0x8c9440";
          magenta = "0x85678f";
          orange  = "0xcc6953";
          red     = "0xa54242";
          white   = "0x707880";
          yellow  = "0xde935f";
        };

        # Bright colors
        bright = {
          black   = "0x373b41";
          blue    = "0x81a2be";
          cyan    = "0x8abeb7";
          green   = "0xb5bd68";
          magenta = "0xb294bb";
          red     = "0xcc6666";
          white   = "0xc5c8c6";
          yellow  = "0xf0c674";
        };
      };
    };
  };
}
