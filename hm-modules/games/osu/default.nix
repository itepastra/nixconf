{ pkgs, ... }: {

  home.packages = [
    (pkgs.symlinkJoin {
      name = "osu-lazer-bin-wrapped";
      paths = [ (pkgs.osu-lazer-bin.override { nativeWayland = true; }) ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/osu! \
          --set PIPEWIRE_LATENCY "12/44100"
      '';
    })
  ];
  services.pipewire = {
    enable = true;
    configs = {
      "17-output-low-latency" = {
        "context.properties" = {
          "default.clock.quantum" = 64;
          "default.clock.min-quantum" = 32;
          "default.clock.max-quantum" = 2048;
        };
      };
    };
  };
}
