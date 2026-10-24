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

        jwt = { };

        chunking = {
          nar-size-threshold = 2 * 1024 * 1024; # 2 MiB
          min-size = 512 * 1024; # 512 KiB
          avg-size = 2 * 1024 * 1024; # 2 MiB
          max-size = 8 * 1024 * 1024; # 8 MiB
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
