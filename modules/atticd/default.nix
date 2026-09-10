{
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.attic.nixosModules.atticd
    ../nginx
    ../postgres
  ];

  age.secrets."atticd/env" = {
    file = ../../secrets/atticd/env.age;
    owner = config.services.atticd.user;
    group = config.services.atticd.group;
    mode = "600";
  };

  services = {
    atticd = {
      enable = true;
      environmentFile = config.age.secrets."atticd/env".path;
      settings = {
        listen = "[::1]:16320";

        allowed-hosts = [
          "[::1]"
          "127.0.0.1"
        ];

        api-endpoint = "http://trench.reef/";

        jwt = { };

        chunking = {
          nar-size-threshold = 64 * 1024; # 64 KiB
          min-size = 16 * 1024; # 16 KiB
          avg-size = 64 * 1024; # 64 KiB
          max-size = 256 * 1024; # 256 KiB
        };

        storage = {
          type = "local";
          path = "/data/atticd/storage";
        };

        database.url = "postgresql:///${config.services.atticd.user}?host=/run/postgresql&user=${config.services.atticd.user}";
      };
    };

    postgresql = {
      ensureDatabases = [ "${config.services.atticd.user}" ];
      ensureUsers = [
        {
          name = config.services.atticd.user;
          ensureDBOwnership = true;
        }
      ];
    };
  };

  systemd.services.atticd.serviceConfig = {
    DynamicUser = lib.mkForce false;
    PrivateUsers = lib.mkForce false;
  };

  users.users.atticd = {
    isSystemUser = true;
    group = "atticd";
  };

  users.groups.atticd = { };

  modules.nginx.proxies = [
    {
      url = "trench.reef";
      proxy_to = "http://[::1]:16320/";
      enableSSL = false;
    }
  ];
}
