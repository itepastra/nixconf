{ config, lib, ... }:
let
  url = "reef.geenit.nl";
in
{
  imports = [
    ../../config/info
    ../zitadel
  ];
  services.netbird = {
    enable = true;
    ui.enable = true;
    server = {
      enable = true;
      enableNginx = true;
      domain = url;
      dashboard = {
        enable = true;
        settings = {
          AUTH_AUTHORITY = "https://auth.geenit.nl/oauth2";
          AUTH_AUDIENCE = "netbird";
          AUTH_CLIENT_ID = "netbird";
          AUTH_SUPPORTED_SCOPES = "openid profile email";
          NETBIRD_TOKEN_SOURCE = "idToken";
        };
      };
      management = {
        enable = true;
        oidcConfigEndpoint = "https://auth.geenit.nl/oauth2/.well-known/openid-configuration";
        turnDomain = "turn.geenit.nl";
      };
      signal.enable = true;
    };
  };

  networking.hosts = {
    "127.0.0.1" = [
      "reef.geenit.nl"
      "auth.geenit.nl"
    ];
  };

  networking.firewall.allowedUDPPorts = [ 3478 ];

  security.acme = {
    acceptTerms = true;
    defaults.email = config.modules.info.noa.email;
    certs = {
      # "reef.geenit.nl" = { };
    };
  };
}
