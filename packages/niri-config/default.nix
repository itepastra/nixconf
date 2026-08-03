{
  pkgs,
  self-pkgs,
  inputs,
  displays,
}:
let
  terminal = "${pkgs.kitty}/bin/kitty";
  launcher = "${self-pkgs.fuzzel-launch}/bin/fuzzel-launch";
  power-menu = "${self-pkgs.fuzzel-power}/bin/fuzzel-power";
  lockscreen = "${pkgs.hyprlock}/bin/hyprlock";
  autostart-string =
    "spawn-at-startup \""
    + pkgs.lib.strings.concatStringsSep "\nspawn-at-startup \"" [
      "keepassxc\""
      "thunderbird\""
    ];

  displays-string = pkgs.lib.strings.concatMapStringsSep "\n" (
    {
      name,
      horizontal,
      vertical,
      refresh-rate,
      horizontal-offset ? 0,
      vertical-offset ? 0,
      scale ? "1",
      transform ? "normal",
      default-column-width ? 0.5,
      default-window-height ? 1.0,
      ...
    }:
    ''
      output "${name}" {
        mode "${builtins.toString horizontal}x${builtins.toString vertical}@${builtins.toString refresh-rate}"
        scale ${scale}
        transform "${transform}"
        position x=${builtins.toString horizontal-offset} y=${builtins.toString vertical-offset}

        layout {
          default-column-width { proportion ${builtins.toString default-column-width}; }
        }
      }
    ''
  ) displays;
in
pkgs.replaceVars ./template.kdl {
  terminal = terminal;
  launcher = launcher;
  power_menu = power-menu;
  lockscreen = lockscreen;

  displays = displays-string;
  autostart = autostart-string;
  xwayland = pkgs.lib.getExe pkgs.xwayland-satellite;

  DEFAULT_AUDIO_SINK = null;
  DEFAULT_AUDIO_SOURCE = null;
}
