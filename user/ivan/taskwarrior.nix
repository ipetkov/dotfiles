{ config, pkgs, ... }:
{
  home.sessionVariables = {
    TASKRC = "${config.programs.taskwarrior.dataLocation}/taskrc";
  };

  home.packages = with pkgs; [
    tasksh
    # NB: do not use the home-manager version of task warrior
    # since it insists on placing the .taskrc file in $HOME
    taskwarrior
  ];
}
