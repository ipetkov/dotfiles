{ pkgs, ... }:
{
  home.packages = with pkgs; [
    tasksh
  ];

  programs.taskwarrior.enable = true;
}
