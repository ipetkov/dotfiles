{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.dotfiles.rust;
in
{
  options.dotfiles.rust.enable = lib.mkEnableOption "rust";

  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
      CARGO_HOME = "${config.xdg.dataHome}/cargo";
    };

    home.packages =
      [
        pkgs.cargo-outdated
        pkgs.rustup
      ]
      ++ lib.lists.optionals pkgs.stdenv.isLinux [
        # binutils now conflicts with clang as well, turning this off for now...
        # binutils # For some reason conflicts on darwin
        pkgs.clang # Provides `cc` for any *-sys crates
      ];
  };
}
