{ homeManagerModules }:

{ config, pkgs, ... }:
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  imports = with homeManagerModules; [
    common
    direnv
    fish
    fzf
    git
    nvim
    rust
    taskwarrior
  ];

  programs.git = {
    userName = "Ivan Petkov";
    userEmail = "ivanppetkov@gmail.com";
    extraConfig = {
      github.user = "ipetkov";
      credential.helper = "osxkeychain";
    };
    signing = {
      # NB: note bang at the end to force that this subkey is used
      # and not direct gpg to use whatever subkey it wants from the
      # parent key (extremely good software...)
      key = "0xBB6F9EFC065832B6!";
      signByDefault = true;
    };
  };

  # 8.3.0 seems broken on darwin :/
  #programs.topgrade.enable = true;

  home.packages = with pkgs; [
    awscli2
    /* cachix */
    fortune
    watch
  ];

  home.sessionVariables = {
    HOMEBREW_NO_ANALYTICS = "1";
  };

  programs.eza.enable = false;

  programs.fish = {
    shellInit = ''
      # Load nix configurations/paths etc.
      source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
    '';

    functions = {
      gitk = "command gitk $argv &";
      fish_greeting = ''
        echo
        fortune -a
        echo
        task
      '';
    };
  };
}
