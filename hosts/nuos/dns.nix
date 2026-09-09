{
  config,
  lib,
  pkgs,
  ...
}:
let
  netbirdInterface = "reef0";
  tldListUrl = "http://scuba.reef/tlds";
  forwardingRulesFile = "/var/lib/netbird-dns/forwarding-rules.txt";
  bootstrapRulesFile = "/var/lib/netbird-dns/bootstrap-forwarding-rules.txt";

  updateScript = pkgs.writeShellScript "update-netbird-dns" ''
    set -euo pipefail

    interface="${netbirdInterface}"
    forwarding_rules="${forwardingRulesFile}"
    bootstrap_rules="${bootstrapRulesFile}"
    url="${tldListUrl}"

    state_dir="$(dirname "$forwarding_rules")"

    ${pkgs.coreutils}/bin/mkdir -p "$state_dir"

    netbird_ip="$(
      ${pkgs.iproute2}/bin/ip -4 -o addr show dev "$interface" \
        | ${pkgs.gawk}/bin/awk '
            {
              split($4, address, "/");
              print address[1];
              exit;
            }
          '
    )"

    if [ -z "$netbird_ip" ]; then
      echo "Could not find an IPv4 address on $interface" >&2
      exit 1
    fi

    echo "NetBird DNS server: $netbird_ip"

    bootstrap_tmp="$bootstrap_rules.tmp"

    printf 'reef %s\n' "$netbird_ip" > "$bootstrap_tmp"
    ${pkgs.coreutils}/bin/chmod 0644 "$bootstrap_tmp"
    ${pkgs.coreutils}/bin/mv -f "$bootstrap_tmp" "$bootstrap_rules"

    # -------------------------------------------------------------------------
    # If we already have a complete rules file, update its resolver IP.
    #
    # This is important when anemone's NetBird IP changes.
    #
    # Example:
    #
    #   reef       10.67.167.130
    #   something  10.67.167.130
    #
    # becomes:
    #
    #   reef       10.67.200.42
    #   something  10.67.200.42
    #
    # before we attempt to download the new list.
    #
    # That means the previous list remains usable even if the web server is
    # temporarily unavailable.
    # -------------------------------------------------------------------------

    if [ -s "$forwarding_rules" ]; then
      updated_tmp="$forwarding_rules.ip-update.tmp"

      ${pkgs.gawk}/bin/awk \
        -v ip="$netbird_ip" '
          /^[[:space:]]*#/ {
            print
            next
          }

          /^[[:space:]]*$/ {
            print
            next
          }

          {
            print $1, ip
          }
        ' \
        "$forwarding_rules" > "$updated_tmp"

      ${pkgs.coreutils}/bin/chmod 0644 "$updated_tmp"

      if ! ${pkgs.diffutils}/bin/cmp -s \
        "$updated_tmp" \
        "$forwarding_rules"
      then
        echo "NetBird IP changed; updating forwarding rules"

        ${pkgs.coreutils}/bin/mv -f \
          "$updated_tmp" \
          "$forwarding_rules"
      else
        ${pkgs.coreutils}/bin/rm -f "$updated_tmp"
      fi
    fi

    # -------------------------------------------------------------------------
    # Download the TLD list.
    #
    # This happens AFTER .reef is known to point at the current anemone IP.
    # Therefore tlds.reef can be resolved through NetBird DNS.
    # -------------------------------------------------------------------------

    downloaded="$(
      ${pkgs.curl}/bin/curl \
        --fail \
        --silent \
        --show-error \
        --location \
        --max-time 30 \
        --connect-timeout 10 \
        "$url"
    )"

    # -------------------------------------------------------------------------
    # Validate and convert the list.
    #
    # Input:
    #
    #   reef
    #   something
    #   gumgle
    #
    # Output:
    #
    #   reef       10.67.167.130
    #   something  10.67.167.130
    #   gumgle     10.67.167.130
    #
    # Empty lines and lines beginning with # are ignored.
    # -------------------------------------------------------------------------

    rules_tmp="$forwarding_rules.download.tmp"

    printf '%s\n' "$downloaded" |
      ${pkgs.gawk}/bin/awk \
        -v ip="$netbird_ip" '
          /^[[:space:]]*#/ {
            next
          }

          /^[[:space:]]*$/ {
            next
          }

          {
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0)

            # Accept normal DNS names.
            #
            # Examples:
            #   reef
            #   something
            #   foo.reef
            #   internal.example
            #
            if ($0 !~ /^([A-Za-z0-9-]+\.)*[A-Za-z0-9-]+$/) {
              printf "Invalid DNS name in TLD list: %s\n", $0 \
                > "/dev/stderr"
              exit 1
            }

            print $0, ip
          }
        ' > "$rules_tmp"

    # Never replace a working configuration with an empty one.
    if [ ! -s "$rules_tmp" ]; then
      echo "Downloaded TLD list is empty" >&2
      ${pkgs.coreutils}/bin/rm -f "$rules_tmp"
      exit 1
    fi

    ${pkgs.coreutils}/bin/chmod 0644 "$rules_tmp"

    if [ -f "$forwarding_rules" ] &&
       ${pkgs.diffutils}/bin/cmp -s \
         "$rules_tmp" \
         "$forwarding_rules"
    then
      echo "NetBird forwarding rules are unchanged"
      ${pkgs.coreutils}/bin/rm -f "$rules_tmp"
      exit 0
    fi

    echo "Installing new NetBird forwarding rules:"
    ${pkgs.coreutils}/bin/cat "$rules_tmp"

    ${pkgs.coreutils}/bin/mv -f \
      "$rules_tmp" \
      "$forwarding_rules"

  '';
in
{
  # ===========================================================================
  # dnscrypt-proxy
  # ===========================================================================

  services.dnscrypt-proxy = {
    enable = true;

    settings = {
      listen_addresses = [
        "0.0.0.0:53"
        "[::]:53"
      ];

      enable_hot_reload = true;

      forwarding_rules = forwardingRulesFile;

      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];

        cache_file = "/var/lib/dnscrypt-proxy/public-resolvers.md";

        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";

        refresh_delay = 72;
      };

      require_nolog = true;
      require_nofilter = true;
      require_dnssec = false;

      block_undelegated = false;

      cache_size = 4096;

      cloaking_rules = pkgs.writeText "cloaking-rules.txt" ''
        home.itepastra.nl 192.168.42.2
      '';
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };

  networking.resolvconf.useLocalResolver = true;

  services.netbird.clients = builtins.listToAttrs (
    lib.map (val: {
      name = "${val}";
      value = {
        config.DisableDNS = true;
      };
    }) config.modules.netbird.clients
  );

  systemd.tmpfiles.rules = [
    "d /var/lib/netbird-dns 0755 netbird-dns-updater netbird-dns-updater - -"
  ];

  users.groups.netbird-dns-updater = { };
  users.users.netbird-dns-updater = {
    isSystemUser = true;
    group = "netbird-dns-updater";
  };

  systemd.services.update-netbird-dns = {
    description = "Update NetBird DNS forwarding rules";

    wants = [
      "network-online.target"
      "netbird-reef.service"
    ];

    after = [
      "network-online.target"
      "netbird-reef.service"
    ];

    serviceConfig = {
      Type = "oneshot";

      ExecStart = updateScript;

      # The updater needs to:
      #   - inspect reef1
      #   - access the network
      #   - write /var/lib/netbird-dns
      #
      # It doesn't need any special capabilities.
      User = "netbird-dns-updater";
      Group = "netbird-dns-updater";

      # Don't leave the temporary download around after a failure.
      UMask = "0022";
    };
  };

  systemd.timers.update-netbird-dns = {
    description = "Periodically update NetBird DNS forwarding rules";

    wantedBy = [
      "timers.target"
    ];

    timerConfig = {
      # Give NetBird a little time to establish reef1 after boot.
      OnBootSec = "30s";

      OnUnitActiveSec = "5min";

      # Avoid doing the request at exactly the same time on every machine.
      RandomizedDelaySec = "30s";

      # Run after a reboot if a scheduled execution was missed.
      Persistent = true;
    };
  };
}
