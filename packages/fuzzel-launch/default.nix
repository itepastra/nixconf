{
  writeShellScriptBin,
  fuzzel,
  lib,
}:
writeShellScriptBin "fuzzel-launch" ''
  ${lib.getExe fuzzel}
''
