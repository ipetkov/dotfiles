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
          aliases = {
            # `jj stack <revset>` to include specific revs
            # https://web.archive.org/web/20260501225239/https://isaaccorbrey.com/notes/jujutsu-megamerges-for-fun-and-profit
            stack = [
              "rebase"
              "--after"
              "trunk()"
              "--before"
              "closest_merge(@)"
              "--revision"
            ];

            # `jj stage` to include the whole stack after the megamerge
            # https://web.archive.org/web/20260501225239/https://isaaccorbrey.com/notes/jujutsu-megamerges-for-fun-and-profit
            stage = [
              "stack"
              "closest_merge(@)+::@- ~ empty()"
            ];

            # `jj restack` to rebase your changes onto `trunk()`
            # https://web.archive.org/web/20260501225239/https://isaaccorbrey.com/notes/jujutsu-megamerges-for-fun-and-profit
            restack = [
              "rebase"
              "--onto"
              "trunk()"
              "--source"
              "roots(trunk()..) & mutable()"
              "--simplify-parents"
            ];
          };

          git.private-commits = lib.mkDefault "description(glob:'wip:*') | description(glob:'private:*')";

          revsets.bookmark-advance-to = "@-";

          revset-aliases = lib.mkDefault {
            # The `trunk().. &` bit is an optimization to scan for non-`mine()` commits
            # only among commits that are not in `trunk()`
            "immutable_heads()" = "builtin_immutable_heads() | (trunk().. & ~mine())";

            # https://web.archive.org/web/20260501225239/https://isaaccorbrey.com/notes/jujutsu-megamerges-for-fun-and-profit
            "closest_merge(to)" = "heads(::to & merges())";
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
            name = cfgGit.settings.user.name;
            email = cfgGit.settings.user.email;
          };
        };
      };

      programs.mergiraf = {
        enable = true;
        enableJujutsuIntegration = true;
      };
    })
    (lib.mkIf (cfgJJ.enable && cfgJJ.settings.ui.show-cryptographic-signatures) {
      home.packages = [
        pkgs.gnupg
      ];
    })
  ];
}
