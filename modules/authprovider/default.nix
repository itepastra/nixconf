{ config, pkgs, ... }:
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
    package = pkgs.keycloak.override { plugins = with pkgs.keycloakPlugins; [ junixsocket-common ]; };
    database = {
      type = "postgresql";
      host = "/run/postgresql/";
      createLocally = true;
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
      proxy_to = "http://127.0.0.1:${builtins.toString config.services.keycloak.settings.http-port}";
    }
  ];

  systemd.services.keycloak = {
    after = [ "postgresql.target" ];
    bindsTo = [ "postgresql.target" ];
  };
}
