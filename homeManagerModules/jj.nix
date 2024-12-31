{ config, pkgs, lib, ... }:
let
  cfgGit = config.programs.git;
in
{
  home.packages = [
    pkgs.watchman
  ];

  programs.jujutsu = {
    enable = true;
    settings = {
      core.fsmonitor = "watchman";

      git.private-commits = lib.mkDefault "description(glob:'wip:*') | description(glob:'private:*')";

      revset-aliases = lib.mkDefault {
        # The `trunk().. &` bit is an optimization to scan for non-`mine()` commits
        # only among commits that are not in `trunk()`
        "immutable_heads()" = "builtin_immutable_heads() | (trunk().. & ~mine())";
      };

      ui.pager = "less -FRX";
      user = {
        name = cfgGit.userName;
        email = cfgGit.userEmail;
      };
    };
  };
}
