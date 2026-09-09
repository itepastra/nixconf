{
  pkgs,
  inputs,
  ...
}:
{
  nix.settings = {
    substituters = [ "http://trench.reef/anemone?priority=10" ];
    trusted-substituters = [ "http://trench.reef/anemone" ];

    post-build-hook = "${pkgs.writeScript "upload-to-cache" ''
      ${
        inputs.attic.packages.${pkgs.stdenv.hostPlatform.system}.attic
      }/bin/attic push trench:anemone $OUT_PATHS
    ''}";
  };

  environment.systemPackages = [
    inputs.attic.packages.${pkgs.stdenv.hostPlatform.system}.attic
  ];
}
