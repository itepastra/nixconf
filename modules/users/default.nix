{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [ ../../config/info ];

  users = lib.mkMerge [
    ({
      users = lib.traceValSeq (
        lib.mapAttrs (
          user:
          {
            name,
            ssh-keys,
            password,
            ...
          }:
          {
            description = lib.mkIf (name != "") name;
            openssh.authorizedKeys.keys = ssh-keys;
            isNormalUser = lib.mkIf (user != "root") true;
            extraGroups = [
              "networkmanager"
              "docker"
              "wireshark"
              "dialout"
            ];
            hashedPassword = password;
          }
        ) config.modules.info
      );
    })
    {
      defaultUserShell = pkgs.zsh;
      users = lib.traceValSeq {
        noa = lib.mkIf (config.modules.info ? noa) {
          extraGroups = [
            "wheel"
          ];
        };
      };
    }
  ];
}
