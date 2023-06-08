{ pkgs, ... }:
let
  inherit (pkgs) git gitFull stdenv;
  inherit (stdenv) isDarwin;
in
{
  programs.git = {
    enable = true;
    package = if isDarwin then git else gitFull;

    ignores = [
      "*~"
      ".DS_Store"
      "*.swp"
      "Session.vim"
    ];

    aliases = {
      lg = "log --graph --pretty=format:'%Cred%h%Creset - %G? -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
    };

    extraConfig = {
      core.autoctrlf = "input";
      init.defaultBranch = "main";
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
