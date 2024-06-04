{ lib, config, pkgs, ... }:
let
  cfg = config.modules.games;
in
{
  options.modules.games = {
    enable = lib.mkEnableOption "enable gaming services";
    minecraft.enable = lib.mkEnableOption "enable minecraft";
  };

  imports = [
    ./minecraft.nix
  ];

  config = lib.mkIf cfg.enable {
    modules.games.minecraft.enable = true;
  };
}
