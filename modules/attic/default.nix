{
  pkgs,
  inputs,
  config,
  ...
}:
{
  nix.settings = {
    substituters = [ "http://trench.reef/anemone?priority=10" ];
    trusted-substituters = [ "http://trench.reef/anemone" ];
  };

  environment.systemPackages = [
    inputs.attic.packages.${pkgs.stdenv.hostPlatform.system}.attic
  ];

  programs.attic-client = {
    enable = true;
    package = inputs.attic.packages.${pkgs.stdenv.hostPlatform.system}.attic;
    watchStore = [ "trench:anemone" ];
    settings = {
      default-server = "trench";
      servers.trench = {
        endpoint = "http://trench.reef";
        token-file = config.age.secrets."attic/anemone".path;
      };
    };
  };
}
