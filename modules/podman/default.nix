{ pkgs, lib, ... }:
{
  virtualisation = {
    oci-containers.backend = "podman";
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;

      autoPrune = {
        enable = true;
        dates = "weekly";
      };

    };
  };

  environment.sessionVariables = {
    PODMAN_COMPOSE_WARNING_LOGS = "false";
  };

  environment.systemPackages = [ pkgs.podman-compose ];
}
