let
  getFlakeCompat = path: import path;
  selectGetFlake = { getFlake ? getFlakeCompat, ...}: getFlake;
  getFlake = selectGetFlake builtins;
  flake = getFlake (toString ./..);
in
{
  inherit flake;
}
