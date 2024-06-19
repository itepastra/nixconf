{ lib, config, pkgs, ... }:
{
  options.modules.games.steam = {
    enable = lib.mkEnableOption "enable steam";
  };
  config = lib.mkIf config.modules.games.steam.enable {
    programs = {
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
        gamescopeSession.enable = true;
        dedicatedServer.openFirewall = true;

      };

      gamemode.enable = true;
    };
  };
}
