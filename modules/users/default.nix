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
      users = (
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
            isNormalUser = true;
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
      users = {
        noa = lib.mkIf (config.modules.info ? noa) {
          isNormalUser = true;
          extraGroups = [
            "wheel"
          ];
        };
      };
    }
  ];
}
