{ pkgs, ... }:
{
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.03";

  xdg.enable = true;

  programs.jq.enable = true;

  home.packages = with pkgs; [
    bash-language-server
    fd
    nix-output-monitor
    nix-tree
    ripgrep
    shellcheck
    shfmt
  ];
}
