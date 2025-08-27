{
  pkgs,
  ...
}:
let
  inherit (pkgs)
    lib
    appimageTools
    fetchurl
    nix-update-script
    ;
  pname = "archipelago";
  version = "0.0.8";
  src = fetchurl {
    url = "https://github.com/itepastra/Archipelago/releases/download/${version}/Archipelago_0.6.4_linux-x86_64.AppImage";
    hash = "sha256-TNXaigMURFp9XUpRNVAXeDOYUksLRUuydy4F8yc+2Q8=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;
  extraPkgs = pkgs: [
    pkgs.xsel
    pkgs.xclip
    pkgs.mtdev
  ];
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
    maintainers = with lib.maintainers; [
      pyrox0
      iqubic
    ];
    platforms = lib.platforms.linux;
  };
}
