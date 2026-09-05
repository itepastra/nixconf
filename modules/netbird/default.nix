{ ... }: {
  services.netbird = {
    ui.enable = true;
    clients.reef = {
      port = 51820;
      name = "reef-netbird";
      interface = "reef0";
      hardened = false;
      openFirewall = true;
      openInternalFirewall = true;
      ui.enable = true;
    };
  };
}
