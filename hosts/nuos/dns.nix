{
  pkgs,
  lib,
  config,
  ...
}:
{
  services = {
    dnscrypt-proxy = {
      enable = true;
      settings = {
        listen_addresses = [
          "[::]:53"
          "127.0.0.1:53"
        ];
        sources.public-resolvers = {
          urls = [
            "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
            "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
          ];
          cache_file = "/var/lib/dnscrypt-proxy/public-resolvers.md";
          minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
          refresh_delay = 72;
        };
        ipv6_servers = true;

        require_nolog = true;
        require_nofilter = true;
        require_dnssec = false;

        cache_size = 4096;

        cloaking_rules = pkgs.writeText "cloaking-rules.txt" ''
          home.itepastra.nl 192.168.42.2
        '';
      };
    };
    resolved.enable = false;
  };

  networking.firewall.allowedTCPPorts = [ 53 ];
  systemd.services.dnscrypt-proxy.serviceConfig = {
    stateDirectory = "dnscrypt-proxy";
  };
}
