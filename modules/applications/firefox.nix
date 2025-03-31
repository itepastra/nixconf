{
  lib,
  config,
  pkgs,
  ...
}:
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
      package = (pkgs.firefox.override { nativeMessagingHosts = [ pkgs.passff-host ]; });
      profiles = {
        profile_0 = {
          id = 0;
          name = "profile_0";
          isDefault = true;
          settings = {
            # TODO: add firefox settings of choice
          };
        };
      };
    };

    home.packages = [
      pkgs.pinentry-qt
    ];

    home.file = {
      "ykcs/ykcs11.so".source = "${pkgs.yubico-piv-tool}/lib/libykcs11.so";
    };
  };

}
