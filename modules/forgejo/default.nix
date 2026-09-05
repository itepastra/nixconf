{ ... }:
{
  imports = [
    ../postgres
    ../nginx
  ];

  config = {
    modules.nginx.proxies = [
      {
        url = "git.reef";
        proxy_to = "http://[::1]:2929";
        enableSSL = false;
      }
      {
        url = "git.geenit.nl";
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
          ROOT_URL = "https://git.geenit.nl";
        };
        service.DISABLE_REGISTRATION = true;
      };

      database = {
        type = "postgres";
      };
    };

  };
}
