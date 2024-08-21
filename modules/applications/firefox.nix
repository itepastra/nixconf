{ lib, config, pkgs, ... }:
let
  cfg = config.modules.apps.firefox;
in
{
  options.modules.apps.firefox = {
    enable = lib.mkEnableOption "enable firefox";
  };

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      # TODO: add some default firefox settings
      package = (pkgs.firefox.override { extraNativeMessagingHosts = [ pkgs.passff-host ]; });
    };

    home.packages = [
      pkgs.pinentry-qt
    ];

  };

}
