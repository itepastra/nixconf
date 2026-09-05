{ config, lib, ... }: {
  age.secrets = lib.mkIf config.services.netbird.clients.reef.login.enable {
    "netbird/setup-${config.networking.hostName}" = {
      file = ../../secrets/netbird/setup-${config.networking.hostName}.age;
      owner = "${config.services.netbird.clients.reef.user.name}";
      group = "${config.services.netbird.clients.reef.user.group}";
      mode = "600";
    };
  };

  services.netbird = {
    clients.reef = {
      port = 51820;
      interface = "reef0";

      name = "reef";

      login = {
        enable = true;
        setupKeyFile = config.age.secrets."netbird/setup-${config.networking.hostName}".path;
      };

      config = {
        ManagementURL = {
          Scheme = "https";
          Opaque = "";
          User = null;
          Host = "reef.geenit.nl:443";
          Path = "";
          Fragment = "";
          RawQuery = "";
          RawPath = "";
          RawFragment = "";
          ForceQuery = false;
          OmitHost = false;
        };
      };

      hardened = false;
      openFirewall = true;
      openInternalFirewall = true;
      ui.enable = true;
    };
  };
}
