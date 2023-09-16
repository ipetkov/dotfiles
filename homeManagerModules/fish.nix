{ config, pkgs, lib, inputs, ... }:
{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      if test -n "$IN_NIX_SHELL"
        set --global nix_shell_info "<nix-shell> "
      else
        set --global nix_shell_info ""
      end

      functions --copy fish_prompt fish_prompt_default
      function fish_prompt
        echo -n -s "$nix_shell_info"
        fish_prompt_default
      end

      # TODO: remove this after 3.6.2 is released
      # https://github.com/fish-shell/fish-shell/issues/9705#issuecomment-1611920724
      function __fish_is_zfs_feature_enabled -a feature target -d "Returns 0 if the given ZFS feature is available or enabled for the given full-path target (zpool or dataset), or any target if none given"
        type -q zpool
        or return
        set -l pool (string replace -r '/.*' "" -- $target)
        set -l feature_name ""
        if test -z "$pool"
            set feature_name (zpool get -H all 2>/dev/null | string match -r "\s$feature\s")
        else
            set feature_name (zpool get -H all $pool 2>/dev/null | string match -r "$pool\s$feature\s")
        end
        if test $status -ne 0 # No such feature
            return 1
        end
        set -l state (echo $feature_name | cut -f3)
        string match -qr '(active|enabled)' -- $state
        return $status
    end
    '';

    shellAliases = lib.optionalAttrs config.programs.eza.enable {
      ll = "eza -la";
    };
  };

  programs.bat.enable = true;
  programs.eza.enable = lib.mkDefault true;
}
