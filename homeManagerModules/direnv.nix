{
  config,
  lib,
  nixosConfig,
  ...
}:
let
  cfg = config.dotfiles.direnv;
  cfgNix = nixosConfig.dotfiles.nix;
  useLix = nixosConfig != null && cfgNix.useLix;
in
{
  options.dotfiles.direnv.enable = lib.mkOption {
    default = true;
    description = "Whether to enable direnv";
    type = lib.types.bool;
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    })

    (lib.mkIf (cfg.enable && useLix) {
      programs.direnv.nix-direnv.package = cfgNix.lixPackageSet.nix-direnv;
    })
  ];
}
