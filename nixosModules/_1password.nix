{ config, lib, ... }:
{
  nixpkgs.config.allowUnfree = true;
  security.polkit.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = lib.mkDefault [ "ivan" ];
  };
}
