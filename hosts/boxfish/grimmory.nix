{ inputs, ... }:
{
  imports = [
    inputs.tixpkgs.nixosModules."services/grimmory"
  ];

  services.grimmory = {
    enable = true;
    port = 25000;
    dataDir = "/data/grimmory/data";
    bookdropDir = "/data/grimmory/bookdrop";
  };
}
