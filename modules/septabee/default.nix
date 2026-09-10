{ inputs, pkgs, ... }: {
  imports = [
    inputs.septabee.nixosModules."x86_64-linux".default
  ];

  programs.septabee = {
    enable = true;
    wayland-deps = true;
    package = inputs.septabee.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
}
