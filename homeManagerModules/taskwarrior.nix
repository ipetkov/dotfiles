{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    tasksh
    # NB: do not use the home-manager version of task warrior
    # since it insists on placing the .taskrc file in $HOME
    taskwarrior3
  ];
}
