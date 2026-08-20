{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
let
  url = "https://home.itepastra.nl";
in
{
  imports = [
    ../postgres # home-assistant needs postgres to work consistently
    ../nginx # for creating a proxy
  ];

  config = {

    modules.nginx.proxies = [
      {
        url = lib.elemAt (lib.strings.splitString "://" url) 1;
        proxy_to = "[::1]:8123";
      }
    ];

    age.secrets = {
      "ha/ns" = {
        file = ../../secrets/home-assistant/ns.age;
        owner = "hass";
        group = "hass";
      };
    };

    services.glances.enable = false;

    services = {
      home-assistant = {
        enable = true;
        extraComponents = [
          "caldav"
          "discord"
          "dsmr"
          "esphome"
          "github"
          "glances"
          "google_translate"
          "heos"
          "homekit_controller"
          "hue"
          "immich"
          "jellyfin"
          "matter"
          "met"
          "nederlandse_spoorwegen"
          "otbr"
          "radarr"
          "radio_browser"
          "seventeentrack"
          "sonarr"
          "spotify"
          "steam_online"
          "syncthing"
          "tado"
          "thread"
          "wake_on_lan"
          "webdav"
          "wled"
        ];

        customComponents = [
          inputs.self.packages.${pkgs.stdenvNoCC.hostPlatform.system}.ecoflow-energy-ha
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
            external_url = url;
            internal_url = url;
          };

          http = {
            server_host = [
              "::1"
              "127.0.0.1"
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

      postgresql = {
        ensureDatabases = [ "hass" ];
        ensureUsers = [
          {
            name = "hass";
            ensureDBOwnership = true;
          }
        ];
      };
      matter-server = {
        enable = true;
        package = pkgs.matterjs-server;
      };
      openthread-border-router = {
        enable = true;
        radio = {
          device = "/dev/serial/by-id/usb-1a86_USB_Single_Serial_585A039379-if00";
          baudRate = 460800;
        };
        backboneInterfaces = [
          "enp42s0"
          "lo"
        ];
      };
    };

    systemd.tmpfiles.rules = [
      "f ${config.services.home-assistant.configDir}/automations.yaml 0755 hass hass"
    ];

    systemd.services.matter-server.serviceConfig = {
      MemoryDenyWriteExecute = lib.mkForce false;
    };

    nixpkgs.config.permittedInsecurePackages = [
      "openssl-1.1.1w"
    ];
  };
}
