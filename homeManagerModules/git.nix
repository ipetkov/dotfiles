{ pkgs, ... }:
let
  inherit (pkgs) git stdenv;
  inherit (stdenv) isDarwin;
in
{
  programs.git = {
    enable = true;
    package = git.override {
      guiSupport = !isDarwin; # Tcl/tk stuff is currently broken on darwin
      withSsh = !isDarwin; # Use Apple specific ssh build on darwin (e.g. keychain support etc.)
      withLibsecret = !isDarwin;
    };

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
      blame.ignoreRevsFile = ".git-blame-ignore-revs";
      core.autoctrlf = "input";
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
