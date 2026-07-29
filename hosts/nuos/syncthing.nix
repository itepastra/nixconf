{ pkgs, ... }: {
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    guiAddress = "127.0.0.1:8385";
  };
}
