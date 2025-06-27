{
  pkgs,
  ...
}:
pkgs.buildDotnetModule {
  pname = "autopelago";
  version = "0.10.0-unstable-2025-06-02";

  src = pkgs.fetchFromGitHub {
    owner = "airbreather";
    repo = "Autopelago";
    rev = "c3413875e5ec3e79cd5f4a74b4270d2dfd96083c";
    hash = "sha256-w4jSijCJrOnujiUxqaUPyUoQ4FXteGVmUaB6z4ReKWA=";
  };

  runtimeDeps = [ pkgs.libGL ];

  projectFile = "src/Autopelago/Autopelago.csproj";

  dotnet-sdk = pkgs.dotnetCorePackages.sdk_9_0;
  dotnet-runtime = pkgs.dotnetCorePackages.runtime_9_0;

  nugetDeps = ./autopelago_deps.json;

  selfContainedBuild = true;

  meta = {
    mainProgram = "Autopelago";
  };
}
