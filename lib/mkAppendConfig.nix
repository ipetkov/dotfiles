{ mkNixosSystem }:

# Make a nixosSystem and add a `appendConfig` attribute, which, when
# invoked with the same parameters that `mkNixosSystem` accepts,
# will produce a new nixosSystem with the new parameters merged in.
#
# Specifically:
# - specifying a `system` parameter will replace the old definition.
#   Omitting it will retain the old definition.
# - specifying an `inputs` attrSet will merge it with the old definition,
#   overwriting any collisions (be careful with overwriting inputs this way).
# - specifying a `rootConfig` module will include it within the system
#   definition (just like manually specifying an `import`).
let
  mkAppendConfig = origArgs:
    let
      origRes = mkNixosSystem origArgs;

      mergeArgs = { system ? origArgs.system, inputs ? {}, rootConfig }: origArgs // {
        inherit system;
        inputs = origArgs.inputs // inputs;
        rootConfig = {
          imports = [
            origArgs.rootConfig
            rootConfig
          ];
        };
      };
    in
      origRes // { appendConfig = newArgs: mkAppendConfig (mergeArgs newArgs); };
in
  mkAppendConfig
