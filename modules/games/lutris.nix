{ lib, config, pkgs, ... }:
let
  cfg = config.modules.games.lutris;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [
      (pkgs.lutris.override {
        extraPkgs = pkgs: [
          pkgs.wineWowPackages.waylandFull
          pkgs.gamescope
        ];
      })
    ];
  };
}
