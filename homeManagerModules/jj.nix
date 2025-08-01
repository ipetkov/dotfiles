{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfgGit = config.programs.git;
  cfgJJ = config.programs.jujutsu;
in
{
  config = lib.mkMerge [
    ({
      programs.jujutsu = {
        enable = true;
        settings = {
          git.private-commits = lib.mkDefault "description(glob:'wip:*') | description(glob:'private:*')";

          revset-aliases = lib.mkDefault {
            # The `trunk().. &` bit is an optimization to scan for non-`mine()` commits
            # only among commits that are not in `trunk()`
            "immutable_heads()" = "builtin_immutable_heads() | (trunk().. & ~mine())";
          };

          templates.draft_commit_description = lib.mkDefault ''
            concat(
              coalesce(description, "wip: "),
              surround(
                "\nJJ: This commit contains the following changes:\n", "",
                indent("JJ:     ", diff.summary()),
              ),
              "\nJJ: ignore-rest\n",
              diff.git(),
            )
          '';

          ui = {
            pager = "less -FRX";
            show-cryptographic-signatures = true;
          };

          user = {
            name = cfgGit.userName;
            email = cfgGit.userEmail;
          };
        };
      };

      programs.mergiraf.enable = true;
    })
    (lib.mkIf (cfgJJ.enable && cfgJJ.settings.ui.show-cryptographic-signatures) {
      home.packages = [
        pkgs.gnupg
      ];
    })
  ];
}
