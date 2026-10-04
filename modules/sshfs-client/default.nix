{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.services.sharedMount;
in
{
  options.services.sharedMount = {
    mountPoint = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/shared";
      description = "Where to mount the share locally";
    };

    identityFile = lib.mkOption {
      type = lib.types.str;
      description = "Path to the SSH private key";
    };

    localUser = lib.mkOption {
      type = lib.types.str;
      description = "Local user who will own the mount";
    };
  };

  config = {
    environment.systemPackages = [ pkgs.sshfs ];
    systemd.mounts = [
      {
        what = "shared@cuttlefish.machine.reef:/shared";
        where = "/mnt/anemone";
        type = "fuse.sshfs";
        options = lib.concatStringsSep "," [
          "defaults"
          "_netdev"
          "allow_other"
          "IdentityFile=${cfg.identityFile}"
          "reconnect"
          "ServerAliveInterval=15"
        ];
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        requires = [ "network-online.target" ];
      }
    ];

    systemd.automounts = [
      {
        where = "/mnt/anemone";
        wantedBy = [ "multi-user.target" ];
        automountConfig.TimeoutIdleSec = "600";
      }
    ];
  };
}
