{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
let
  attic = inputs.attic.packages.${pkgs.stdenv.hostPlatform.system}.attic;
in
{
  imports = [
    inputs.pepoapkgs.nixosModules.attic-toggler
  ];

  age.secrets."attic/anemone" = {
    file = ../../secrets/attic/anemone.age;
    mode = "600";
  };

  services.attic-toggler = {
    enable = true;
    token = config.age.secrets."attic/anemone".path;
    publicKey = "anemone:f/wBQ8yB5geTn96NjwRfbcoEvr8QuykN0iu0Rf2zUC8=";
    homeSsids = [ "niet-bestaand-netwerk" ];
    watchStore = {
      enable = true;
    };
  };
}
