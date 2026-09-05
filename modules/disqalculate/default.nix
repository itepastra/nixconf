{
  config,
  inputs,
  pkgs,
  ...
}:
{

  age.secrets = {
    "discord/disqalculate" = {
      file = ../../secrets/discord/disqalculate.age;
      owner = "disqalculate";
      group = "disqalculate";
      mode = "600";
    };
  };

  users = {
    users = {
      disqalculate = {
        isSystemUser = true;
        group = "disqalculate";
      };
    };
    groups.disqalculate = { };
  };

  systemd.services."disqalculate" = {
    enable = true;
    wants = [
      "network-online.target"
    ];
    after = [
      "network-online.target"
    ];
    wantedBy = [ "default.target" ];
    restartTriggers = [ inputs.disqalculate.packages.${pkgs.stdenv.hostPlatform.system}.default ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${
        inputs.disqalculate.packages.${pkgs.stdenv.hostPlatform.system}.default
      }/bin/disqalculate";
      ExecStop = "${pkgs.busybox}/bin/pkill disqalculate";
      RuntimeDirectory = "disqalculate";
      RootDirectory = "/run/disqalculate";
      User = "disqalculate";
      NoNewPrivileges = true;
      ProtectHome = true;
      ProtectProc = "noaccess";
      ProcSubset = "pid";
      ProtectClock = true;
      ProtectKernelLogs = true;
      ProtectSystem = "strict";
      ProtectHostname = true;
      PrivateTmp = true;
      PrivateDevices = true;
      PrivateUsers = true;
      RestrictAddressFamilies = "AF_INET";
      ProtectKernelTunables = true;
      RestrictNamespaces = true;
      CapabilityBoundingSet = "";
      EnvironmentFile = config.age.secrets."discord/disqalculate".path;
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
