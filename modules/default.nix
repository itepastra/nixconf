{ lib, ... }:
lib.genAttrs (lib.attrNames (
  lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./.)
)) (name: import (./. + "/${name}"))
