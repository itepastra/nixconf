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
        "discord"
        "dsmr"
        "caldav"
        "esphome"
        "github"
        "glances"
        "google_translate"
        "heos"
        "hue"
        "immich"
        "jellyfin"
        "met"
        "nederlandse_spoorwegen"
        "radarr"
        "radio_browser"
        "sonarr"
        "spotify"
        "steam_online"
        "syncthing"
        "tado"
        "wake_on_lan"
        "webdav"
        "wled"
        "homekit_controller"
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
        "automation ui" = "!include automations.yaml";

        recorder.db_url = "postgresql://@/hass";

        homeassistant = {
          external_url = "https://home.itepastra.nl";
          internal_url = "https://home.itepastra.nl";
        };

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
