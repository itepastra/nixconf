{ pkgs, ... }:

{
  home.packages = with pkgs; [
    (symlinkJoin {
      name = "vesktop";
      paths = [
        (writeShellScriptBin "vesktop" ''${vesktop}/bin/vesktop --enable-features=UseOzonePlatform --ozone-platform=wayland'')
        (writeShellScriptBin "Vesktop" ''${vesktop}/bin/Vesktop --enable-features=UseOzonePlatform --ozone-platform=wayland'')
        vesktop
      ];
    })
  ];
}
