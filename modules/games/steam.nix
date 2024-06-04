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

        package = pkgs.steam.override {
          extraPkgs = pkgs: with pkgs; [
            xorg.libXcursor
            xorg.libXi
            xorg.libXinerama
            xorg.libXScrnSaver
            libpng
            libpulseaudio
            libvorbis
            stdenv.cc.cc.lib
            libkrb5
            keyutils
          ];
        };
      };

      gamemode.enable = true;
    };
  };
}
