{ lib, config, pkgs, ... }:
let
  cfg = config.modules.apps;
in
{
  options.modules.apps = {
    enable = lib.mkEnableOption "enable desktop applications";
  };

  imports = [
    ./firefox.nix
    ./git.nix
    ./kitty.nix
    ./zsh.nix
    ./thunderbird.nix
  ];

  config = lib.mkIf cfg.enable {
    modules.apps = {
      firefox.enable = true;
      git.enable = true;
      kitty.enable = true;
      zsh = {
        enable = true;
        enableAliases = true;
      };
    };
  };
}
