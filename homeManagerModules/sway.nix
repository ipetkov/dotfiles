{ pkgs, ... }:
{
  imports = [
    # Alacritty is the default terminal in the config,
    # so ensure our config is pulled in
    ./alacritty.nix
  ];

  xdg.configFile."sway/config".source = ../config/sway/config;
  xdg.configFile."waybar/config".source = ../config/waybar/config;


  home.packages = with pkgs; [
    mako # notification daemon
    waybar
  ];

  # Allow starting up sway (which should exec a systemd call that
  # sway-session.target has started) to then kick off other systemd
  # units (e.g. redshift, etc.)
  systemd.user.targets.sway-session = {
    Unit = {
      Description = "sway compositor session";
      Documentation = [ "man:systemd.special(7)" ];
      BindsTo = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      After = [ "graphical-session-pre.target" ];
    };
  };
}
