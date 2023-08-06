{ config, lib, ... }:
let
  cfg = config.dotfiles._1password;
in
{
  options.dotfiles._1password.enable = lib.mkEnableOption "1Password";

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;
    security.polkit.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = [
        config.users.users.ivan.name
      ];
    };
  };
}
