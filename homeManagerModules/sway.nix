{ config, lib, pkgs, myPkgs, ... }:
let
  fishcfg = config.programs.fish;
in
{
  imports = [
    # Pull in GTK themes for wofi and just about everything else.
    ./gtk.nix
  ];

  # Alacritty is the default terminal in the config,
  # so ensure our config is pulled in
  dotfiles.alacritty.enable = true;

  xdg.configFile."mako/config".source = ../config/mako/config;
  xdg.configFile."sway/config".source = ../config/sway/config;
  xdg.configFile."waybar/config".source = ../config/waybar/config;

  home.packages = with pkgs; [
    mako # notification daemon
    myPkgs.swaynagmode
    waybar # status bar
    wofi # launcher
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

  programs.fish.loginShellInit = lib.mkIf fishcfg.enable ''
      if test -z "$DISPLAY"; and test (tty) = "/dev/tty1"
        # Use systemd-cat here to capture sway logs
        exec systemd-cat --identifier=sway sway
      end
  '';
}
