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
        proxy_to = "[::1]:28727";
      }
    ];

    services = {
      mealie = {
        enable = true;
        port = 28727;
        database.createLocally = true;
      };

    };
  };
}
