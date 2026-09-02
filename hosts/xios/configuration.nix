{
  config,
  lib,
  pkgs,
  inputs,
  platform,
  ...
}:
{
  boot.supportedFilesystems = [
    "btrfs"
    "ext4"
    "tempfs"
  ];

  environment.systemPackages = [
    inputs.disko.${platform}.disko-install
  ];

  isoImage.isoName = lib.mkForce "disko-nixos-${config.system.nixos.label}-${platform}.iso";

  networking.wireless.enable = lib.mkForce true;

  nixpkgs.overlays = [
    (final: prev: {
      # Prevent mbrola-voices (~650MB) from being on the live media
      espeak = prev.espeak.override {
        mbrolaSupport = false;
      };
    })
  ];
}
