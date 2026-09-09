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
          nar-size-threshold = 64 * 1024; # 64 KiB
          min-size = 16 * 1024; # 16 KiB
          avg-size = 64 * 1024; # 64 KiB
          max-size = 256 * 1024; # 256 KiB
        };

        storage = {
          type = "local";
          path = "/data/attic/storage";
        };
        database.url = lib.mkIf config.services.postgresql.enable "postgresql:///${config.services.atticd.user}";
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

  modules.nginx.proxies = [
    {
      url = "trench.reef";
      proxy_to = "http://[::1]:16320/";
      enableSSL = false;
    }
  ];
}
