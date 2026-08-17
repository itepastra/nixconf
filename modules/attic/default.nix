{
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [ inputs.attic.nixosModules.atticd ];

  services = {
    atticd = {
      enable = true;
      environmentFile = "/data/attic/private";
      settings = {
        storage.path = "/data/attic/storage";
        database.url = lib.mkIf config.services.postgresql.enable "postgresql://localhost/attic";
      };
    };

    postgresql = {
      ensureDatabases = [ "attic" ];
      ensureUsers = [
        {
          name = config.atticd.user;
          ensureDBOwnership = true;
        }
      ];
    };

  };
}
