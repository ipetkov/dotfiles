{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.taskwarrior;
in
{
  options.dotfiles.taskwarrior.enable = lib.mkEnableOption "taskwarrior";

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.tasksh
      # NB: do not use the home-manager version of task warrior
      # since it insists on placing the .taskrc file in $HOME
      pkgs.taskwarrior3
    ];

    programs.fish.functions.fish_greeting = "task";
  };
}
