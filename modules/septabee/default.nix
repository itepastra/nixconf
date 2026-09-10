{ inputs, pkgs, ... }: {
  programs.septabee = {
    enable = true;
    wayland-deps = true;
    package = inputs.septabee.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
}
