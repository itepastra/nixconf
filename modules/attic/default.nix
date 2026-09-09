{
  pkgs,
  inputs,
  config,
  ...
}:
let
  attic = inputs.attic.packages.${pkgs.stdenv.hostPlatform.system}.attic;
in
{
  age.secrets."attic/anemone" = {
    file = ../../secrets/attic/anemone.age;
    mode = "600";
  };

  environment.systemPackages = [
    attic
  ];

  systemd.services.attic-watch-store = {
    description = "Attic watch store";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    environment.ATTIC_CONFIG = (pkgs.formats.toml { }).generate "attic-config.toml" {
      default-server = "trench";
      servers.trench = {
        endpoint = "http://trench.reef";
        token-file = config.age.secrets."attic/anemone".path;
      };
    };
    serviceConfig = {
      ExecStart = "${attic}/bin/attic watch-store trench:anemone";
      Restart = "on-failure";
      RestartSec = 10;
    };
  };

  nix.settings = {
    substituters = [ "http://trench.reef/anemone?priority=10" ];
    trusted-substituters = [ "http://trench.reef/anemone" ];
  };
}
