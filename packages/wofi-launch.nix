{ pkgs, ... }:
pkgs.writeShellScriptBin "wofi-launch" ''
  ${pkgs.wofi}/bin/wofi --show drun
''
