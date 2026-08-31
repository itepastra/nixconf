{ config, ... }:
let
  url = "auth.geenit.nl";
in
{
  imports = [
    ../postgres
    ../nginx
  ];

  services.postgresql = {
    ensureDatabases = [ "keycloak" ];
    ensureUsers = [
      {
        name = "keycloak";
        ensureDBOwnership = true;
      }
    ];
  };
  services.keycloak = {
    enable = true;
    database = {
      type = "postgresql";
      host = "localhost";
      createLocally = false;
    };

    settings = {
      http-enabled = true;
      http-port = 29919;

      hostname = "https://${url}";
      proxy-headers = "xforwarded";
    };
  };

  modules.nginx.proxies = [
    {
      url = url;
      proxy_to = "127.0.0.1:${builtins.toString config.services.keycloak.settings.http-port}";
    }
  ];
}
