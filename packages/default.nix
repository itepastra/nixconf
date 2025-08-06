{ nixpkgs }:
let
  allSystems = [
    "x86_64-linux" # 64-bit Intel/AMD Linux
    "aarch64-linux" # 64-bit ARM Linux
    "x86_64-darwin" # 64-bit Intel macOS
    "aarch64-darwin" # 64-bit ARM macOS
  ];
  forAllSystems =
    f:
    nixpkgs.lib.genAttrs allSystems (
      system:
      f {
        inherit system;
        pkgs = import nixpkgs { inherit system; };
      }
    );
in
forAllSystems (
  { pkgs, system }:
  let
    call = path: import path { inherit pkgs system; };
  in
  {
    autopelago = call ./autopelago;
    melonloader = call ./melon.nix;
    fuzzel-launch = call ./fuzzel-launch.nix;
    fuzzel-power = call ./fuzzel-power.nix;
  }
)
