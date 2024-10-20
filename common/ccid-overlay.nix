{ config, pkgs, ... }: {
  nixpkgs.overlays = [
    (self: super: {
      ccid = super.ccid.overrideAttrs (old: rec {
        pname = "ccid";
        version = "1.5.5";
        src = super.fetchurl {
          url = "https://ccid.apdu.fr/files/${pname}-${version}.tar.bz2";
          hash = "sha256-GUcI91/jadRd18Feiz6Kfbi0nPxVV1dMoqLnbvEsoMo=";
        };
        postPatch = ''
          patchShebangs .
          substituteInPlace src/Makefile.in --replace-fail /bin/echo echo
        '';
      });
    })
  ];
}
