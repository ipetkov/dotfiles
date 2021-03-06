{ pkgs, ... }:
{
  programs.fzf = {
    enable = true;
    defaultCommand = "rg --files --hidden --glob !.git";
    fileWidgetCommand = "rg --files --hidden --glob !.git";
  };

  home.packages = with pkgs; [
    # Ensure we include ripgrep for defaultCommand above
    ripgrep
  ];
 }
