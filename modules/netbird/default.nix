{ config, lib, ... }:
let
  url = "reef.geenit.nl";
  token = "SPL7ZK9RUFbbbRk3DEU4KS5YezXwa6TdWifIW88PVVwBF1Kzj3uJNzlFvXhS4ObWM7KPtiZN4HDrWHABNTyXZd";
in
{
  imports = [
    ../../config/info
    ../authprovider
    ../nginx
  ];

  services.netbird = {
    enable = true;

    server = {
      enable = true;
      enableNginx = true;
      domain = "reef.geenit.nl";

      dashboard = {
        enable = true;
        settings = {
          AUTH_AUTHORITY = "https://auth.geenit.nl/realms/reef";
          AUTH_CLIENT_ID = "netbird";
          AUTH_AUDIENCE = "netbird";
          AUTH_SUPPORTED_SCOPES = "openid profile email";
          NETBIRD_TOKEN_SOURCE = "idToken";
          USE_AUTH0 = false;
        };
      };

      management = {
        enable = true;
        oidcConfigEndpoint = "https://auth.geenit.nl/realms/reef/.well-known";
        turnDomain = "turn.geenit.nl";
        disableSingleAccountMode = true;

        settings = {
          IdpManagerConfig = {
            ManagerType = "keycloak";
            ClientConfig = {
              Issuer = "https://auth.geenit.nl/realms/reef";
              TokenEndpoint = "https://auth.geenit.nl/realms/reef/protocol/openid-connect/token";
              ClientID = "netbird";
              ClientSecret = token;
              GrantType = "client_credentials";
            };
            ExtraConfig = { };
          };

          DeviceAuthorizationFlow = {
            Provider = "hosted";
            ProviderConfig = {
              Audience = "netbird";
              Domain = "https://auth.geenit.nl/realms/reef";
              ClientID = "netbird";
              ClientSecret = token;
              TokenEndpoint = "https://auth.geenit.nl/realms/reef/protocol/openid-connect/token";
              DeviceAuthEndpoint = "https://auth.geenit.nl/realms/reef/protocol/openid-connect/auth/device";
              Scope = "openid profile email";
              UseIDToken = true;
            };
          };

          PKCEAuthorizationFlow = {
            ProviderConfig = {
              Audience = "netbird";
              ClientID = "netbird";
              ClientSecret = "";
              AuthorizationEndpoint = "https://auth.geenit.nl/realms/reef/protocol/openid-connect/auth";
              TokenEndpoint = "https://auth.geenit.nl/realms/reef/protocol/openid-connect/token";
              Scope = "openid profile email";
              RedirectURLs = [ "http://localhost:53000" ];
              UseIDToken = true;
            };
          };
        };
      };
      signal.enable = true;
    };
  };

  modules.nginx.other = [
    {
      url = "reef.geenit.nl";
    }
  ];

}
