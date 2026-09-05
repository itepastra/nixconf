{ config, ... }: {
  services.netbird = {
    clients.reef = {
      port = 51820;
      interface = "reef0";

      name = "reef";

      login = {
        enable = true;
        setupKeyFile = config.age.secrets."netbird/setup-${config.networking.hostName}".path;

        config.ManagementURL = "https://reef.geenit.nl:443";
      };

      hardened = false;
      openFirewall = true;
      openInternalFirewall = true;
      ui.enable = true;
    };
  };
}
