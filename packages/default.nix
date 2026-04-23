{ nixpkgs, inputs }:
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
  {
    archipelago = pkgs.callPackage ./archipelago { };
    fuzzel-launch = pkgs.callPackage ./fuzzel-launch { };
    fuzzel-power = pkgs.callPackage ./fuzzel-power { inherit inputs; };
    vvvvvv-ap = pkgs.callPackage ./vvvvvv-ap { };
  }
)
