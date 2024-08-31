{ lib, config, pkgs, ... }:
let
  cfg = config.modules.apps.thunderbird;
in
{
  options.modules.apps.thunderbird = {
    enable = lib.mkEnableOption "enable thunderbird";
  };


  config = lib.mkIf cfg.enable {
    accounts.email.accounts =
      let gpg_key = "A16CDCBF1472541F";
      in
      {
        "noa-voorwaarts" = {
          address = "noa@voorwaarts.nl";
          gpg = {
            signByDefault = true;
            key = gpg_key;
          };
          imap = {
            host = "mail.voorwaarts.nl";
            port = 993;
          };
          primary = true;
          realName = "Noa Aarts";
          smtp = {
            host = "mail.voorwaarts.nl";
            port = 587;
            tls.useStartTls = true;
          };
          thunderbird.enable = true;
          userName = "noa@voorwaarts.nl";
        };
        "noa-itepastra" = {
          address = "noa@itepastra.nl";
          gpg = {
            signByDefault = true;
            key = gpg_key;
          };
          imap = {
            host = "mail.itepastra.nl";
            port = 993;
          };
          realName = "Noa Aarts";
          smtp = {
            host = "mail.itepastra.nl";
          };
          thunderbird.enable = true;
          userName = "noa@itepastra.nl";
        };
        "itepastra-gmail" = {
          address = "itepastra@gmail.com";
          flavor = "gmail.com";
          thunderbird.enable = true;
          realName = "Noa Aarts";
          userName = "itepastra";
        };
      };

    programs.thunderbird = {
      enable = true;
      # TODO: add some default firefox settings
      package = pkgs.thunderbird;
      profiles = {
        "default" = {
          isDefault = true;
          withExternalGnupg = true;
        };
      };
    };
  };

}
