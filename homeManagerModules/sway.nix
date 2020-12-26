{ pkgs, ... }:
{
  imports = [
    # Alacritty is the default terminal in the config,
    # so ensure our config is pulled in
    ./alacritty.nix
  ];

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;

    config = {
      modifier = "Mod4"; # My keyboard has Win and Alt swapped
      terminal = "alacritty";
    };
  };

  home.packages = with pkgs; [
    swaylock
    swayidle
    wl-clipboard
    mako # notification daemon
    dmenu
  ];
}
