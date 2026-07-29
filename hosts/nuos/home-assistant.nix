{
  pkgs,
  config,
  ...
}:
let
  ha = {
    url = "https://home.itepastra.nl";
  };

in
{
  config = {

    age.secrets = {
      "ha/ns" = {
        file = ../../secrets/home-assistant/ns.age;
        owner = "hass";
        group = "hass";
      };
    };

    services.glances.enable = false;

    services.home-assistant = {
      enable = true;
      extraComponents = [
        "esphome"
        "met"
        "radio_browser"
        "wled"
        "heos"
        "hue"
        "tado"
        "dsmr"
        "google_translate"
        "syncthing"
        "spotify"
        "github"
        "nederlandse_spoorwegen"
        # "caldav"
        "discord"
      ];

      config = {
        default_config = { };
        # "sensor" = [
        #   {
        #     platform = "nederlandse_spoorwegen";
        #     api_key_path = config.age.secrets."ha/ns".path;
        #     routes = [
        #       {
        #         name = "Utrecht_Vaartsche-Leiden";
        #         from = "Utvr";
        #         to = "Ledn";
        #       }
        #       {
        #         name = "Utrecht-Delft";
        #         from = "Ut";
        #         to = "Dt";
        #       }
        #     ];
        #   }
        # ];
        "api" = { };
        "automation manual" = [ ];
        "automation ui" = "!include automations.yaml";

        http = {
          server_host = [
            "::"
            "0.0.0.0"
          ];
          trusted_proxies = [ "::1" ];
          use_x_forwarded_for = true;
        };

        openFirewall = true;
      };

      package = (
        pkgs.home-assistant.override {
          extraPackages =
            py: with py; [
              psycopg2
            ];
        }
      );
      # .overrideAttrs (oldAttrs: {
      # 	doInstallCheck = false;
      # });

    };

    systemd.tmpfiles.rules = [
      "f ${config.services.home-assistant.configDir}/automations.yaml 0755 hass hass"
    ];

    nixpkgs.config.permittedInsecurePackages = [
      "openssl-1.1.1w"
    ];

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "hass" ];
      ensureUsers = [
        {
          name = "hass";
          ensureDBOwnership = true;
        }
      ];
    };
  };
}
