{ lib, ... }:
let
  url = "http://images.reef";
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
        enableSSL = false;
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
