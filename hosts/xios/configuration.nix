{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{

  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"
  ];

  boot.supportedFilesystems = [
    "btrfs"
    "ext4"
    "tempfs"
  ];

  environment.systemPackages = [
    inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.disko-install
  ];

  image.fileName = lib.mkForce "disko-nixos-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";

  networking.wireless.enable = lib.mkForce true;

  nixpkgs.overlays = [
    (final: prev: {
      # Prevent mbrola-voices (~650MB) from being on the live media
      espeak = prev.espeak.override {
        mbrolaSupport = false;
      };
    })
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
