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

  systemd.tmpfiles.rules = [
    "C /root/.config/attic/config.toml 0600 root root - ${
      (pkgs.formats.toml { }).generate "attic-config.toml" {
        default-server = "trench";
        servers.trench = {
          endpoint = "http://trench.reef";
          token-file = config.age.secrets."attic/anemone".path;
        };
      }
    }"
  ];

  nix.settings = {
    substituters = [ "http://trench.reef/anemone?priority=10" ];
    trusted-public-keys = [ "anemone:f/wBQ8yB5geTn96NjwRfbcoEvr8QuykN0iu0Rf2zUC8=" ];
    trusted-substituters = [ "http://trench.reef/anemone" ];
  };
}
