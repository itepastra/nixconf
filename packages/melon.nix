{
  pkgs,
  ...
}:
pkgs.buildDotnetModule rec {
  pname = "melonloader";
  version = "0.7.0-unstable-2025-06-06";

  src = pkgs.fetchFromGitHub {
    owner = "LavaGang";
    repo = "MelonLoader";
    rev = "af66ccdb81beaa1b48dffedc06619afdb73cfe0f";
    hash = "sha256-9yIwnYAoRJyFeRfOjQ+6di9Z/iWHaPjMXPa6olj4r6s=";
  };

  runtimeDeps = [
    pkgs.icu
  ];

  projectFile = "MelonLoader.sln";

  dotnet-sdk = pkgs.dotnetCorePackages.sdk_9_0;
  dotnet-runtime = pkgs.dotnetCorePackages.runtime_9_0;

  nugetDeps = ./melon_deps.json;

  meta = {
    mainProgram = "MelonLoader";
  };
}
