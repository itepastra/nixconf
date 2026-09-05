{ config, ... }: {
  age.secrets = {
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

      environment = {
        NG_MANAGEMENT_URL = "https://reef.geenit.nl:443";
      };

      login = {
        enable = false;
        setupKeyFile = config.age.secrets."netbird/setup-${config.networking.hostName}".path;
      };

      hardened = false;
      openFirewall = true;
      openInternalFirewall = true;
      ui.enable = true;
    };
  };
}
