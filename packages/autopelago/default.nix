{
  pkgs,
  ...
}:
pkgs.buildDotnetModule {
  pname = "autopelago";
  version = "0.10.4";

  src = pkgs.fetchFromGitHub {
    owner = "airbreather";
    repo = "Autopelago";
    rev = "v0.10.4";
    hash = "sha256-qTHJ5nuB5NF+ju5gmxkP/s7uRjrNpkkyBzkhD/0n4D4=";
  };

  runtimeDeps = [ pkgs.libGL ];

  projectFile = "src/Autopelago/Autopelago.csproj";

  dotnet-sdk = pkgs.dotnetCorePackages.sdk_9_0;
  dotnet-runtime = pkgs.dotnetCorePackages.runtime_9_0;

  nugetDeps = ./deps.json;

  selfContainedBuild = true;

  meta = {
    mainProgram = "Autopelago";
  };
}
