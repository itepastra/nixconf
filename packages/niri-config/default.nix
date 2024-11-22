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
  lockscreen = "${pkgs.swaylock}/bin/swaylock";
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
      horizontal-offset,
      scale,
      ...
    }:
    ''
      output "${name}" {
        mode "${builtins.toString horizontal}x${builtins.toString vertical}@${builtins.toString refresh-rate}"
        scale ${scale}
        transform "normal"
        position x=${builtins.toString horizontal-offset} y=0
      }
    ''
  ) displays;
in
pkgs.substituteAll {
  src = ./template.kdl;
  terminal = terminal;
  launcher = launcher;
  power_menu = power-menu;
  lockscreen = lockscreen;

  displays = displays-string;
  autostart = autostart-string;
}
