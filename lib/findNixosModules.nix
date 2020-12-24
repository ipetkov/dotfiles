{ lib, findNixFiles }:

nixosModulesDir:
 let
   inherit (builtins) listToAttrs map stringLength substring toString;
   inherit (lib) removePrefix removeSuffix;
   inherit (lib.strings) concatImapStrings splitString toUpper;

   modulePaths = findNixFiles nixosModulesDir;
   convertToName = path:
   let
     name = removePrefix ((toString nixosModulesDir) + "/") (removeSuffix ".nix" (toString path));
     parts = splitString "/" name;
     capitalize = s: (toUpper (substring 0 1 s)) + (substring 1 (stringLength s) s);
   in
   concatImapStrings (i: n: if i == 1 then n else (capitalize n)) parts;
   mapMod = path: lib.nameValuePair (convertToName path) (import path);
 in
  listToAttrs (map mapMod modulePaths)
