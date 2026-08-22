{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
{
  imports = [
    ../postgres # home-assistant needs postgres to work consistently
    ../nginx # for creating a proxy
  ];

  config = {

    modules.nginx.proxies = [
      {
        url = "recipes.geenit.nl";
        proxy_to = "http://127.0.0.1:28727";
      }
    ];

    services = {
      mealie = {
        enable = true;
        port = 28727;
        listenAddress = "127.0.0.1";
        settings = {
          ALLOW_SIGNUP = "False";
          BASE_URL = "https://recipes.geenit.nl";
          TZ = "europe/amsterdam";
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 28728 ];
  };
}
