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
  wallpapers =
    let
      automapaper-configs = builtins.map (
        {
          name,
          horizontal-resolution,
          vertical-resolution,
          ...
        }:
        let
          display-shader = pkgs.substituteAll {
            src = ../../modules/automapaper/display-with_vars.glsl;
            background = inputs.nix-colors.lib.conversions.hexToGLSLVec "101012";
            foreground = inputs.nix-colors.lib.conversions.hexToGLSLVec "192291";
          };
          state-shader = ../../modules/automapaper/state-game_of_life.glsl;
          init-shader = ../../modules/automapaper/init.glsl;

          # General configurations
          cycles = 2000;
          tps = 30;
          horizontal-dot-size = 10;
          vertical-dot-size = 10;
        in
        (import ../../modules/automapaper/config.nix {
          inherit (pkgs) writeTextFile;
          inherit
            init-shader
            state-shader
            display-shader
            tps
            cycles
            ;
          display = name;
          horizontal = builtins.div horizontal-resolution horizontal-dot-size;
          vertical = builtins.div vertical-resolution vertical-dot-size;
        })
      ) displays;
    in
    pkgs.lib.strings.concatMapStringsSep "\n" (
      file:
      ''spawn-at-startup "${
        inputs.automapaper.packages.${pkgs.system}.automapaper
      }/bin/automapaper" "-C" "${file}/config.toml"''
    ) automapaper-configs;
  autostart-string =
    "spawn-at-startup \""
    + pkgs.lib.strings.concatStringsSep "\nspawn-at-startup \"" [
      "${pkgs.dunst}/bin/dunst\""
      "${pkgs.xwayland-satellite}/bin/xwayland-satellite\""
      "spotify\""
      "keepassxc\""
      "thunderbird\""
      "${pkgs.waybar}/bin/waybar\""
    ];

  displays-string = pkgs.lib.strings.concatMapStringsSep "\n" (
    {
      name,
      horizontal-resolution,
      vertical-resolution,
      refresh-rate,
      horizontal-position,
    }:
    ''
      output "${name}" {
        mode "${builtins.toString horizontal-resolution}x${builtins.toString vertical-resolution}@${refresh-rate}"
        scale 1
        transform "normal"
        position x=${builtins.toString horizontal-position} y=0
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
  wallpapers = wallpapers;

  displays = displays-string;
  autostart = autostart-string;
}
