{ lib, mkHost }:

{ nixosConfigurationsDir, system }:
let
  inherit (builtins) listToAttrs pathExists readDir;
  inherit (lib.attrsets) attrNames filterAttrs mapAttrs nameValuePair;
  inherit (lib.strings) concatStringsSep hasSuffix removeSuffix;

  dirContents = readDir nixosConfigurationsDir;
  rootModules = attrNames (filterAttrs (k: type: type == "regular" && hasSuffix ".nix" k) dirContents);

  mkPath = relativePaths: nixosConfigurationsDir + "/${concatStringsSep "/" relativePaths}";
  rootConfigs = listToAttrs (map
    (path: nameValuePair (removeSuffix ".nix" path) (mkPath [path]))
    rootModules
  );

  rootDirs = attrNames (filterAttrs
    (k: type: type == "directory" && pathExists (mkPath [k "default.nix"]))
    dirContents
  );
  rootDirConfigs = listToAttrs (map
    (path: nameValuePair path (mkPath [path "default.nix"]))
    rootDirs
  );

  initHost = _: rootConfig: mkHost { inherit rootConfig system; };
in
  mapAttrs initHost (rootConfigs // rootDirConfigs)
