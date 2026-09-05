{
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  cursor_name = "Bibata-Rainbow-Modern";
  cursor_src = pkgs.runCommand cursor_name { } ''
    mkdir -p $out/share/icons
    ln -s ${
      pkgs.fetchzip {
        name = cursor_name;
        url = "https://github.com/ful1e5/Bibata_Cursor_Rainbow/releases/download/v1.1.2/${cursor_name}.tar.gz";
        hash = "sha256-Ps+IKPwQoRwO9Mqxwc/1nHhdBT2R25IoeHLKe48uHB8=";
      }
    } $out/share/icons/${cursor_name}
  '';
in
{
  stylix = {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";
    cursor = lib.mkIf osConfig.hardware.graphics.enable {
      name = cursor_name;
      package = cursor_src;
      size = 32;
    };
    enable = true;
    polarity = "dark";
    opacity = {
      terminal = 0.2;
      popups = 0.66;
    };
    override = {
      # I liked my background colors from before, make it in more spots
      base00 = "0a000a";
    };
    targets = {
      neovim.enable = false;
      waybar.enable = false;
      fuzzel.enable = false;
      firefox.profileNames = [ "profile_0" ];
      qt = {
        enable = true;
        platform = "qtct";
      };
    };
  };
}
