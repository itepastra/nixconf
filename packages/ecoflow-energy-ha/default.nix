{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  aiofiles,
  distutils,
  nix-update-script,
}:

buildHomeAssistantComponent rec {
  owner = "shuette42";
  domain = "ecoflow_energy";
  version = "1.16.0";

  src = fetchFromGitHub {
    owner = "shuette42";
    repo = "ecoflow-energy-ha";
    tag = "v${version}";
    hash = "sha256-LXAMJSnrzDK/loz5Vmdng7boCyBUxG8bqe6LRvDZTkQ=";
  };

  dependencies = [
  ];

  dontBuild = true;

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    changelog = "https://github.com/shuette42/ecoflow-energy-ha/releases/tag/v${version}";
    description = "Integration for Home Assistant to interact with ecoflow devices";
    homepage = "https://github.com/shuette42/ecoflow-energy-ha";
    license = licenses.mit;
  };
}
