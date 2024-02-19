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
      commit.verbose = "true";
      core.autoctrlf = "input";
      fetch.fsckobjects = "true";
      init.defaultBranch = "main";
      merge.conflictstyle = "zdiff3";
      pull.ff = "only";
      push.default = "matching";
      rebase.autosquash = "true";
      receive.fsckObjects = "true";
      rerere.enabled = "true";
      transfer.fsckobjects = "true";
    };

    difftastic = {
      enable = true;
      display = "side-by-side";
    };
  };
}
