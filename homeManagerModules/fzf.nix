{ pkgs, ... }:
{
  programs.fzf = {
    enable = true;
    defaultCommand = "rg --files --hidden --glob !.git";
    fileWidgetCommand = "rg --files --hidden --glob !.git";
    changeDirWidgetCommand = "fd --type d";
  };

  home.packages = with pkgs; [
    # Ensure we include ripgrep and fd for the commands above
    ripgrep
    fd
  ];
 }
