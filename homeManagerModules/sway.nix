{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.sway;
  fishcfg = config.programs.fish;
in
{
  options.dotfiles.sway.enable = lib.mkEnableOption "sway";

  config = lib.mkIf cfg.enable {
    dotfiles = {
      # Alacritty is the default terminal in the config,
      # so ensure our config is pulled in
      alacritty.enable = true;
      # Pull in GTK themes for wofi and just about everything else.
      gtk.enable = true;
    };

    xdg.configFile."mako/config".source = ../config/mako/config;
    xdg.configFile."sway/config".source = ../config/sway/config;
    xdg.configFile."waybar/config".source = ../config/waybar/config;

    nixpkgs.config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "discord"
      ];

    home.packages = [
      pkgs.blueberry # bluetooth configuration
      pkgs.discord
      pkgs.firefox
      pkgs.mako # notification daemon
      (pkgs.callPackage ../pkgs/swaynagmode.nix { })
      pkgs.waybar # status bar
      pkgs.wofi # launcher
      pkgs.xdg-utils # for xdg-open, make links clickable from outside firefox
    ];

    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
      XDG_CURRENT_DESKTOP = "sway";
    };

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
  };
}
