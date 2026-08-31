{ config, ... }: {
  imports = [
    ../postgres
    ../nginx
  ];

  age = {
    identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets."zitadel/master" = {
      file = ../../secrets/zitadel/master.age;
      owner = config.services.zitadel.user;
      group = config.services.zitadel.group;
    };
  };

  services.postgresql = {
    ensureDatabases = [ "zitadel" ];

    ensureUsers = [
      {
        name = config.services.zitadel.user;
        ensureDBOwnership = true;
      }
    ];
  };

  services.zitadel = {
    enable = true;
    settings = {
      Port = 29919;
      Database.postgres.DSN = "postgresql://zitadel@localhost:5432/zitadel?sslmode=disable";

      ExternalDomain = "auth.geenit.nl";
      ExternalPort = 443;
      ExternalSecure = true;
    };

    tlsMode = "external";
    masterKeyFile = config.age.secrets."zitadel/master".path;
  };

  modules.nginx.proxies = [
    {
      url = "auth.geenit.nl";
      proxy_to = "127.0.0.1:${builtins.toString config.services.zitadel.settings.Port}";
    }
  ];
}
