{ pkgs, ... }:
let
  ap =
    {
      lib,
      appimageTools,
      fetchurl,
      nix-update-script,
      extraPackages ? [ ],
    }:
    let
      pname = "archipelago";
      version = "0.6.2";
      src = fetchurl {
        url = "https://github.com/ArchipelagoMW/Archipelago/releases/download/${version}-rc3/Archipelago_${version}_linux-x86_64.AppImage";
        hash = "sha256-5uoHIKaBPgZEg5rPx1yv/uqb2iBQs6uYLRPO9Z1N2Wg=";
      };

      appimageContents = appimageTools.extractType2 { inherit pname version src; };
    in
    appimageTools.wrapType2 {
      inherit pname version src;
      extraPkgs =
        pkgs:
        [
          pkgs.xsel
          pkgs.xclip
          pkgs.mtdev
        ]
        ++ extraPackages;
      extraInstallCommands = ''
        install -Dm444 ${appimageContents}/archipelago.desktop -t $out/share/applications
        substituteInPlace $out/share/applications/archipelago.desktop \
          --replace-fail 'opt/Archipelago/ArchipelagoLauncher' "archipelago"
        cp -r ${appimageContents}/usr/share/icons $out/share
      '';

      passthru.updateScript = nix-update-script { };

      meta = {
        description = "Multi-Game Randomizer and Server";
        homepage = "https://archipelago.gg";
        changelog = "https://github.com/ArchipelagoMW/Archipelago/releases/tag/${version}";
        license = lib.licenses.mit;
        mainProgram = "archipelago";
        maintainers = with lib.maintainers; [ pyrox0 ];
        platforms = lib.platforms.linux;
      };
    };
in
pkgs.callPackage ap { }
