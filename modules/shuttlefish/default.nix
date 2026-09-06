{
  config,
  inputs,
  pkgs,
  ...
}:
{

  age.secrets = {
    "discord/shuttlefish" = {
      file = ../../secrets/discord/shuttlefish.age;
      owner = "shuttlefish";
      group = "shuttlefish";
      mode = "600";
    };
  };

  users = {
    users = {
      shuttlefish = {
        isSystemUser = true;
        group = "shuttlefish";
      };
    };
    groups.shuttlefish = { };
  };

  systemd.services."shuttlefish" = {
    enable = true;
    wants = [
      "network-online.target"
    ];
    after = [
      "network-online.target"
    ];
    wantedBy = [ "default.target" ];
    restartTriggers = [ inputs.shuttlefish.packages.${pkgs.stdenv.hostPlatform.system}.default ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${
        inputs.shuttlefish.packages.${pkgs.stdenv.hostPlatform.system}.default
      }/bin/shuttlefish";
      ExecStop = "${pkgs.busybox}/bin/pkill shuttlefish";
      RuntimeDirectory = "shuttlefish";
      # RuntimeDirectoryMode = 0750;
      User = "shuttlefish";
      # NoNewPrivileges = true;
      # ProtectHome = true;
      # ProtectProc = "noaccess";
      # ProcSubset = "pid";
      # ProtectClock = true;
      # ProtectKernelLogs = true;
      # ProtectSystem = "strict";
      # ProtectHostname = true;
      # PrivateTmp = true;
      # PrivateDevices = true;
      # PrivateUsers = true;
      # RestrictAddressFamilies = "AF_INET";
      # ProtectKernelTunables = true;
      # RestrictNamespaces = true;
      # CapabilityBoundingSet = "";
      EnvironmentFile = config.age.secrets."discord/shuttlefish".path;
      BindReadOnlyPaths = [
        "/nix/store"
        "/etc/ssl"
        "/etc/static/ssl"
        "/etc/resolv.conf"
        "/bin/sh"
      ];
      Restart = "always";
      RestartSec = 10;
      TimeoutStopSec = 10;
    };
    unitConfig = {
      StartLimitInterval = 400;
      StartLimitBurst = 30;
    };
  };
}
