# Module for adding binary caches for neovim nightly builds, specifically coming
# from https://github.com/mjlbach/neovim-nightly-overlay
#
# Unfortunately there isn't a way to configure nix options from within a home-manager
# user configuration (well, at least my understanding of nix modules isn't advanced
# enough to figure one out), so we'll manage this as a companion module.
#
# But to avoid adding this cache needlessly, it will only be done if our hmNvim
# module is actually enabled!
{ config, lib, ... }:

let
  hmUsers = config.home-manager.users;
  configHasNeovimNightly = userConfig:
    let
      neovim = userConfig.programs.neovim;
    in
      # NB: can't seem to compare here that neovim.package == defaultPackage of
      # the overlay file, so checking the name is a good approximation
      neovim.enable && neovim.package.pname == "neovim-nightly";
  neovimNightlyUsed = lib.any configHasNeovimNightly (lib.attrValues hmUsers);
in
{
  config = lib.mkIf neovimNightlyUsed {
    nix = {
      binaryCaches = ["https://nix-community.cachix.org"];
      binaryCachePublicKeys = ["nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
    };
  };
}
