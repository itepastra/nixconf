# Example to create a bios compatible gpt partition
{ lib, ... }:
{
  disko.devices = {
    disk.main = {
      device = lib.mkDefault "/dev/disk/by-id/ata-SSD_PHISON_256GB_PS3110-S10C_8EFA076507E704408024";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            priority = 1;
            name = "ESP";
            start = "1M";
            end = "1024M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "/rootfs" = {
                  mountpoint = "/";
                };

                "/home" = {
                  mountOptions = [ "compress=zstd" ];
                  mountpoint = "/home";
                };

                "/nix" = {
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                  mountpoint = "/nix";
                };
              };
            };
          };
        };
      };
    };
  };
}
