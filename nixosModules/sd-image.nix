{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
  ];

  # NB: linuxPackages_latest (5.14 as of now) does not build at this commit,
  # so we'll use the current LTS kernel (currently 5.10)
  boot.kernelPackages = pkgs.linuxPackages;

  # Don't bother compressing, we're going to decompress it right back out
  sdImage.compressImage = false;
}
