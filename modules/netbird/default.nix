{ config, lib, ... }:
let
  url = "reef.geenit.nl";
  token = "SPL7ZK9RUFbbbRk3DEU4KS5YezXwa6TdWifIW88PVVwBF1Kzj3uJNzlFvXhS4ObWM7KPtiZN4HDrWHABNTyXZd";
in
{
  imports = [
    ../../config/info
    ../nginx
  ];

  services.nginx.virtualHosts."reef.geenit.nl" = {
    locations."/relay/" = {
      proxyWebsockets = true;
      proxyPass = "127.0.0.1.29919";
    };
    locations."/ws-proxy/" = {
      proxyWebsockets = true;
      proxyPass = "127.0.0.1.29919";
    };
    locations."/signalexchange.SignalExchange/" = {
      proxyWebsockets = true;
      proxyPass = "127.0.0.1.29919";
    };
    locations."/management.ManagementService/" = {
      proxyWebsockets = true;
      proxyPass = "127.0.0.1.29919";
    };
    locations."/api/" = {
      proxyWebsockets = true;
      proxyPass = "127.0.0.1.29919";
    };
    locations."/oauth2/" = {
      proxyWebsockets = true;
      proxyPass = "127.0.0.1.29919";
    };
    locations."/" = {
      proxyWebsockets = true;
      proxyPass = "127.0.0.1.29918";
    };
  };

  modules.nginx.other = [
    {
      url = "reef.geenit.nl";
    }
  ];

}
