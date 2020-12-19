{ pkgs, ... }:
{
  programs.git = {
    enable = true;

    ignores = [
      "*~"
      ".DS_Store"
      "*.swp"
    ];

    aliases = {
      lg = "log --graph --pretty=format:'%Cred%h%Creset - %G? -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
    };

    extraConfig = {
      core.autoctrlf = "input";
      github.user = "ipetkov";
      merge.conflictstyle = "diff3";
      pull.ff = "only";
      push.default = "matching";
      rerere.enabled = "true";
    };

    delta = {
      enable = true;
      options = {
        side-by-side = true;
      };
    };
  };
}
