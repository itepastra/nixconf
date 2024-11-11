{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.apps;
in
{
  imports = [
    ./firefox.nix
    ./git.nix
    ./kitty.nix
    ./zsh.nix
    ./thunderbird.nix
  ];
}
