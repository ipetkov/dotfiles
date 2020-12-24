{ lib }:

let findNixModules = rootDir:
  let
    inherit (lib.attrsets) attrValues filterAttrs mapAttrs;
    inherit (lib.lists) flatten;
    inherit (lib.strings) hasSuffix;

    dirContents = builtins.readDir rootDir;
    nixModules = filterAttrs (k: type: type == "directory" || hasSuffix ".nix" k) dirContents;
    nestedModules = mapAttrs (name: type: 
      let
        path = rootDir + "/${name}";
      in
        if (type == "regular") then
          path
        else if (type == "directory") then
          (findNixModules path)
        else builtins.throw ("unexpected type: " + type)
    ) nixModules;
  in
    flatten (attrValues nestedModules);
in
  findNixModules
