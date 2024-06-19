{ pkgs, ... }:

{
  home.packages = with pkgs; [
     (symlinkJoin {
     	name = "discord";
     	paths = [
     		(writeShellScriptBin "discord" ''${discord}/bin/discord --enable-features=UseOzonePlatform --ozone-platform=wayland'')
     		(writeShellScriptBin "Discord" ''${discord}/bin/Discord --enable-features=UseOzonePlatform --ozone-platform=wayland'')
     		discord
     	];
     })
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
