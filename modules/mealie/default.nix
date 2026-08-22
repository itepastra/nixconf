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
        proxy_to = "http://[::1]:28727";
      }
    ];

    services = {
      mealie = {
        enable = true;
        port = 28727;
        listenAddress = "::1";
        settings = {
          ALLOW_SIGNUP = "False";
          BASE_URL = "https://recipes.geenit.nl:443";
          TZ = "europe/amsterdam";
        };
      };
    };
  };
}
