{ pkgs, ... }:
pkgs.writeShellScriptBin "fuzzel-launch" ''
  ${pkgs.fuzzel}/bin/fuzzel
''
