{ config, lib, ... }:
{
  imports = [
    ../../config/info
    ../nginx
    ../podman
  ];

  users.users."netbird" = {
    isSystemUser = true;
    group = "netbird";
  };
  users.groups.netbird = { };

  age.secrets = {
    "netbird/config.yaml" = {
      file = ../../secrets/netbird/config.yaml;
      owner = "netbird";
      group = "netbird";
      mode = "600";
    };
    "netbird/dashboard.env" = {
      file = ../../secrets/netbird/dashboard.env;
      owner = "netbird";
      group = "netbird";
      mode = "600";
    };
  };

  virtualisation.oci-containers.containers = {
    netbird-dashboard = {
      image = "docker.io/netbirdio/dashboard:latest";
      autoStart = true;
      environmentFiles = [ "${config.age.secrets."netbird/dashboard.env".path}" ];
      ports = [ "127.0.0.1:29918:80" ];

      user = "${toString config.users.users.netbird.uid}:${toString config.users.groups.netbird.gid}";
    };

    netbird-server = {
      image = "docker.io/netbirdio/netbird-server:latest";
      autoStart = true;
      ports = [
        "127.0.0.1:29919:80"
        "3478:3478/udp"
      ];
      volumes = [
        "netbird_data:/var/lib/netbird"
        "${config.age.secrets."netbird/config.yaml".path}:/etc/netbird/config.yaml"
      ];
      user = "${toString config.users.users.netbird.uid}:${toString config.users.groups.netbird.gid}";
    };
  };

  services.nginx.virtualHosts."reef.geenit.nl" = {
    locations."/relay/" = {
      proxyWebsockets = true;
      proxyPass = "http://127.0.0.1:29919";
    };
    locations."/ws-proxy/" = {
      proxyWebsockets = true;
      proxyPass = "http://127.0.0.1:29919";
    };
    locations."/signalexchange.SignalExchange/" = {
      proxyWebsockets = true;
      proxyPass = "http://127.0.0.1:29919";
    };
    locations."/management.ManagementService/" = {
      proxyWebsockets = true;
      proxyPass = "http://127.0.0.1:29919";
    };
    locations."/api/" = {
      proxyWebsockets = true;
      proxyPass = "http://127.0.0.1:29919";
    };
    locations."/oauth2/" = {
      proxyWebsockets = true;
      proxyPass = "http://127.0.0.1:29919";
    };
    locations."/" = {
      proxyWebsockets = true;
      proxyPass = "http://127.0.0.1:29918";
    };
  };

  modules.nginx.other = [
    {
      url = "reef.geenit.nl";
    }
  ];

}
