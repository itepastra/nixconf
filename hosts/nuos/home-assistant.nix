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

    # age.secrets = {
    #   "ha/ns" = {
    #     file = ../../secrets/home-assistant/ns.age;
    #     owner = "hass";
    #     group = "hass";
    #   };
    # };

    services.home-assistant = {
      enable = false;
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

      config =
        let
          windowOpenAutomation = device: entity_1: entity_2: name: {
            alias = "Heater off on window open ${name}";
            description = "Turn off the heater when the window is opened in the room of ${name}";
            triggers = [
              {
                type = "opened";
                device_id = device;
                entity_id = entity_1;
                domain = "binary_sensor";
                trigger = "device";
              }
            ];
            conditions = [ ];
            actions = [
              {
                device_id = device;
                domain = "climate";
                entity_id = entity_2;
                type = "set_hvac_mode";
                hvac_mode = "off";
              }
            ];
            mode = "single";
          };

        in
        {
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
          "automation manual" = [
            (windowOpenAutomation "7d597f356438d1d3cd0c2a7d751cc27b" "binary_sensor.kamer_van_noa_window"
              "climate.kamer_van_noa"
              "noa"
            )
            (windowOpenAutomation "9e94a205cc3d4f4168806e0242763d70" "binary_sensor.kamer_van_sjoerd_window"
              "climate.kamer_van_sjoerd"
              "sjoerd"
            )
            (windowOpenAutomation "435489996d4fc2bfca3cd8beaf781fe4" "binary_sensor.kamer_van_lars_window"
              "climate.kamer_van_lars"
              "lars"
            )
            (windowOpenAutomation "d9b52f250a8392bb3b3b49f08b2ae8bf" "binary_sensor.logeerkamer_window"
              "climate.logeerkamer"
              "guests"
            )
            {
              alias = "Notify noa when at store";
              description = "When Noa comes close to the jumbo, send a notification with the shopping list";
              triggers = [
                {
                  trigger = "zone";
                  entity_id = "person.noa_aarts";
                  zone = "zone.jumbo";
                  event = "enter";
                }
              ];
              conditions = [ ];
              actions = [
                {
                  action = "notify.mobile_app_noa_s_phone";
                  data = {
                    title = "Grocery list";
                    message = ''
                      There {% if states('todo.shopping_list') | int < 2 %} is{%else%}
                      are{%endif%} {{ states('todo.shopping_list')}} {% if
                      states('todo.shopping_list') | int < 2 %} product{%else%}
                      products{%endif%} left on the grocery list.
                    '';
                    # data = {
                    #   actions = [
                    #     {
                    #       action = "URI";
                    #       title = "Open grocery list";
                    #       uri = "${ha.url}/todo?entity_id=todo.shopping_list";
                    #     }
                    #   ];
                    # };
                  };
                }
              ];
              mode = "single";
            }
          ];

          "automation ui" = "!include automations.yaml";

          http = {
            server_host = "::1";
            trusted_proxies = [ "::1" ];
            use_x_forwarded_for = true;
          };
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
