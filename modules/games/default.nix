{ lib, config, pkgs, ... }:
let
  cfg = config.modules.games;
in
{
  options.modules.games = {
    enable = lib.mkEnableOption "enable gaming services";
    minecraft.enable = lib.mkEnableOption "enable minecraft";
    lutris.enable = lib.mkEnableOption "enable lutris";
  };

  imports = [
    ./minecraft.nix
    ./lutris.nix
  ];

  config = lib.mkIf cfg.enable {
    modules.games.minecraft.enable = true;
    modules.games.lutris.enable = true;
  };
}
