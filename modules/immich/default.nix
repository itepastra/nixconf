{ lib, ... }:
let
  url = "https://images.noa.voorwaarts.nl";
in
{
  imports = [
    ../nginx
    ../postgres
  ];
  config = {
    modules.nginx.proxies = [
      {
        url = lib.elemAt (lib.strings.splitString "://" url) 1;
        proxy_to = "http://[::1]:2283";

      }
    ];
    services.immich = {
      enable = true;
      settings = {
        server.externalDomain = url;
      };
    };
  };
}
