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
        database.url = lib.mkIf config.services.postgresql.enable "postgresql://localhost/${config.services.atticd.user}";
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
}
