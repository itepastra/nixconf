{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ ../nginx ];

  config = {
    age = {
      identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      secrets."rsecrets/radicale" = {
        file = ../../secrets/radicale/htpasswd.age;
        owner = "radicale";
        group = "radicale";
      };
    };
    services.radicale = {
      enable = true;
      settings = {
        server.hosts = [ "[::1]:29341" ];
        auth = {
          type = "htpasswd";
          htpasswd_filename = config.age.secrets."rsecrets/radicale".path;
          htpasswd_encryption = "bcrypt";
        };
      };
    };

  };
}
