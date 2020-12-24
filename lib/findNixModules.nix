{ lib }:

rootDir:
let
  inherit (lib.attrsets) filterAttrs mapAttrs' nameValuePair;
  inherit (lib.strings) hasSuffix removeSuffix;

  dirContents = builtins.readDir rootDir;
  nixModules = filterAttrs (k: type: type == "regular" && hasSuffix ".nix" k) dirContents;

  importModule = name: import (rootDir + "/${name}");
in
  mapAttrs' (name: _: (nameValuePair (removeSuffix ".nix" name) (importModule name))) nixModules
