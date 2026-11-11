{ lib, pkgs, ... }: {
  services.openssh.enable = lib.mkDefault true;
  users.users.sharedfs = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO97Yve7hz7krbWA2FOgEihMAoGNmb2PhiwrUB3vXPzS peppidesu@dreadnought"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHDmqN9vOXKI8lgVdmUQF2Bg7yZ6lz5tNZmSJN+syr1w peppidesu@archelon"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH/lSyipLLBKVP/DUN3S0PvS0sLW0wLUrds04OkPT96j noa@leafsheep"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF6GRajE87fIA89q8XqkxJ+jS0+fjFSLiubI8uCachKm noa@vaqita"
    ];
  };
}
