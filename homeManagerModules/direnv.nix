{ config, lib, pkgs, ... }:
{
  xdg.configFile."direnv/direnvrc".source = ../config/direnv/direnvrc;

  home.packages = with pkgs; [
    direnv
  ];

  programs.fish.interactiveShellInit = lib.mkIf config.programs.fish.enable ''
    direnv hook fish | source
  '';
}

