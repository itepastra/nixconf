{ nixpkgs, inputs }:
let
  allSystems = [
    "x86_64-linux"
    "aarch64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
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

  packageNames =
    let
      entries = builtins.readDir ./.;
    in
    builtins.filter (name: entries.${name} == "directory") (builtins.attrNames entries);

in
forAllSystems (
  { pkgs, system }:
  let
    extraArgs = {
      fuzzel-power = { inherit inputs; };
    };
  in
  builtins.listToAttrs (
    map (name: {
      inherit name;
      value = pkgs.callPackage (./. + "/${name}") (extraArgs.${name} or { });
    }) packageNames
  )
)
