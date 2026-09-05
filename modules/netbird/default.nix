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

  services.nginx.virtualHosts."reef.geenit.nl".locations =
    builtins.mapAttrs
      (
        n: v:
        lib.mkMerge [
          v
          ({
            proxyWebsockets = true;
            extraConfig = ''
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Scheme $scheme;
              proxy_set_header X-Forwarded-Proto https;
              proxy_set_header X-Forwarded-Host $host;
              grpc_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            '';
          })
        ]
      )
      {
        "^/(relay|ws-proxy/)" = {
          proxyPass = "http://127.0.0.1:29919";
          extraConfig = ''
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "Upgrade";
            proxy_set_header Host $host;
            proxy_read_timeout 1d;
          '';
        };
        "^/(signalexchange\.SignalExchange|management\.(ManagementService|ProxyService))/" = {
          proxyPass = "http://127.0.0.1:29919";
          extraConfig = ''
            grpc_pass grpc://netbird_server;
            grpc_read_timeout 1d;
            grpc_send_timeout 1d;
            grpc_socket_keepalive on;
          '';
        };
        "^/(api|oauth2)/" = {
          proxyPass = "http://127.0.0.1:29919";
          extraConfig = "proxy_set_header Host $host;";
        };
        "/" = {
          proxyPass = "http://127.0.0.1:29918";
        };
      };

  modules.nginx.other = [
    {
      url = "reef.geenit.nl";
    }
  ];

}
