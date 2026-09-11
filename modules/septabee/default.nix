{ inputs, ... }: {
  imports = [ inputs.septabee.nixosModules.default ];

  programs.septabee = {
    enable = true;
    wayland-deps = true;
    offline = true;
  };
}
