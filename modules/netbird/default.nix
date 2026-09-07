{ config, lib, ... }: {
  options.modules.netbird = {
    clients = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "reef" ];
    };
  };

  config.services.netbird.clients = builtins.listToAttrs (
    lib.imap (idx: val: {
      name = "${val}";
      value = {
        port = 51820 + idx - 1;
        interface = "reef${builtins.toString (idx - 1)}";

        name = "${val}";

        config = {
          ManagementURL = {
            Scheme = "https";
            Opaque = "";
            User = null;
            Host = "reef.geenit.nl:443";
            Path = "";
            Fragment = "";
            RawQuery = "";
            RawPath = "";
            RawFragment = "";
            ForceQuery = false;
            OmitHost = false;
          };
        };

        hardened = false;
        openFirewall = true;
        openInternalFirewall = true;
        ui.enable = false;
      };
    }) config.modules.netbird.clients
  );
}
