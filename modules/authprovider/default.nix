{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  url = "auth.geenit.nl";
in
{
  imports = [
    inputs.authentik.nixosModules.default
    ../nginx
  ];

  age = {
    secrets."authentik/env" = {
      file = ../../secrets/authentik/env.age;
      owner = "authentik";
      group = "authentik";
    };
  };

  services.authentik = {
    enable = true;
    environmentFile = config.age.secrets."authentik/env".path;
    settings = {
    };
    disable_startup_analytics = true;
    avatars = "gravatars";

    nginx = {
      enable = true;
      enableACME = true;
      host = "auth.geenit.nl";
    };
  };
}
