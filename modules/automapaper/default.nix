{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  niri-automapaper = pkgs.writeShellApplication {
    name = "niri-automapaper";

    runtimeInputs = with pkgs; [
      bash
      coreutils
      gnugrep
      jq
      inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.automapaper.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      declare -A WS_IDX_BY_ID
      last_workspace_id=""

      color_for_workspace() {
          local idx="''${1:-}"

          # Fall back to workspace index.
          case "$idx" in
              1) echo "#4c7899" ;;
              2) echo "#7aa2f7" ;;
              3) echo "#9ece6a" ;;
              4) echo "#e0af68" ;;
              5) echo "#bb9af7" ;;
              *) echo "#3b4252" ;;
          esac
      }

      apply_workspace_color() {
          local ws_id="$1"
          local ws_idx="''${WS_IDX_BY_ID[$ws_id]:-}"
          local color

          [[ -n "$ws_id" ]] || return 0

          # Skip duplicate activations.
          if [[ "$last_workspace_id" == "$ws_id" ]]; then
              return 0
          fi
          last_workspace_id="$ws_id"

          color="$(color_for_workspace "$ws_idx")"
          echo "setting color to $color"
          automapaper-ng set c2 "$color"
      }

      # Read niri's JSON event stream line by line.
      stdbuf -oL niri msg --json event-stream | while IFS= read -r line; do
          jq -e . >/dev/null 2>&1 <<<"$line" || continue
          event_type="$(jq -r 'keys[0]' <<<"$line")"

          case "$event_type" in
              WorkspacesChanged)
                  unset WS_IDX_BY_ID
                  declare -A WS_IDX_BY_ID

                  while IFS=$'\t' read -r id idx focused; do
                      WS_IDX_BY_ID["$id"]="$idx"

                      # Apply immediately on startup / rebuild for current focus.
                      if [[ "$focused" == "true" ]]; then
                          apply_workspace_color "$id"
                      fi
                  done < <(
                      jq -r '
                          .WorkspacesChanged.workspaces[]
                          | [
                              .id,
                              .idx,
                              .is_focused
                            ]
                          | @tsv
                      ' <<<"$line"
                  )
                  ;;

              WorkspaceActivated)
                  if [[ "$(jq -r '.WorkspaceActivated.focused' <<<"$line")" == "true" ]]; then
                      apply_workspace_color "$(jq -r '.WorkspaceActivated.id' <<<"$line")"
                  fi
                  ;;

              *)
                  ;;
          esac
      done
    '';
  };
in
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
      services = {
        automapaper = {
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
            Restart = "always";
            RestartSec = 15;
          };
        };
        niri-automapaper = {
          Install = {
            WantedBy = [ "niri.service" ];
          };

          Unit = {
            After = "graphical-session.target";
            Requisite = "graphical-session.target";
          };

          Service = {
            ExecStart = lib.getExe niri-automapaper;
            Type = "exec";
            Restart = "always";
            RestartSec = 15;
          };
        };
      };
    };

    xdg.configFile = {
      "automapaper-ng/config.toml".source =
        pkgs.writers.writeTOML "config.toml" config.modules.automapaper.config;
    };
  };
}
