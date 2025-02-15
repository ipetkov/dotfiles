{ config, lib, ... }:
let
  cfgGit = config.programs.git;
in
{
  programs.jujutsu = {
    enable = true;
    settings = {
      git = {
        private-commits = lib.mkDefault "description(glob:'wip:*') | description(glob:'private:*')";
        subprocess = true;
      };

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
}
