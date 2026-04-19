{
  config,
  options,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  options.modules.automapaper = {
    enable = lib.mkEnableOption "Enable the automapaper service";
    package = lib.mkOption {
      type = lib.types.package;
      default = inputs.automapaper.${pkgs.stdenv.hostPlatform.system}.default;
    };
    config = {
      state_shader_path = lib.mkOption {
        type = lib.types.path;
        default = ./state.glsl;
      };
      display_shader_path = lib.mkOption {
        type = lib.types.path;
        default = ./display.glsl;
      };
      c1 = lib.mkOption {
        type = lib.types.str;
        default = "#000000";
      };
      c2 = lib.mkOption {
        type = lib.types.str;
        default = "#FF0000";
      };
      c3 = lib.mkOption {
        type = lib.types.str;
        default = "#00FF00";
      };
      c4 = lib.mkOption {
        type = lib.types.str;
        default = "#0000FF";
      };
      state_shrink_h = lib.mkOption {
        type = lib.types.int;
        default = 10;
      };
      state_shrink_v = lib.mkOption {
        type = lib.types.int;
        default = 10;
      };
      decay_time = lib.mkOption {
        type = lib.types.float;
        default = 0.5;
      };
      frame_time = lib.mkOption {
        type = lib.types.float;
        default = 0.01666;
      };
    };
  };

  config = lib.mkIf config.modules.automapaper.enable {
    systemd.user = {
      enable = true;
      startServices = "sd-switch";
      services.automapaper = {
        Install = {
          WantedBy = [ "niri.service" ];
        };
        Unit = {
          After = "graphical-session.target";
          Requisite = "graphical-session.target";
        };

        Service = {
          ExecStart = "${lib.getExe inputs.automapaper.packages.${pkgs.stdenv.hostPlatform.system}.default}";
          Type = "exec";
          Restart = "on-failure";
          RestartSec = 15;
        };
      };
    };

    xdg.configFile = {
      "automapaper-ng/config.toml".source =
        pkgs.writers.writeTOML "config.toml" config.modules.automapaper.config;
    };
  };
}
