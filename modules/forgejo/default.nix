{ lib, ... }:
let
  url = "https://git.geenit.nl";
in
{
  imports = [
    ../postgres
    ../nginx
  ];

  config = {
    modules.nginx.proxies = [
      {
        url = lib.elemAt (lib.strings.splitString "://" url) 1;
        proxy_to = "http://[::1]:2929";
      }
    ];
    services.forgejo = {
      enable = true;
      settings = {
        DEFAULT = {
          APP_NAME = "OaGit";
          APP_SLOGAN = "Noa's personal git";
          RUN_MODE = "dev";
        };
        server = {
          DOMAIN = "git.geenit.nl";
          HTTP_PORT = 2929;
          ROOT_URL = url;
        };
        service.DISABLE_REGISTRATION = true;
      };

      database = {
        type = "postgres";
      };
    };

  };
}
