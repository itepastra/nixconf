{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.games.minecraft;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.prismlauncher
    ];
  };
}
