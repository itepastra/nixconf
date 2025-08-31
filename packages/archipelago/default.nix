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
  version = "0.0.9";
  src = fetchurl {
    url = "https://github.com/itepastra/Archipelago/releases/download/${version}/Archipelago_0.6.4_linux-x86_64.AppImage";
    hash = "sha256-gpTRUjzj5cWVb8khIw1P4pV7Cmd9nVIcBBxLqpptW9o=";
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
    platforms = lib.platforms.linux;
  };
}
