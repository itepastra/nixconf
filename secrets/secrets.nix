let
  noa = "age1yubikey1qv9qr2l4srzpt9h9ess58hv4m58njxw50356vgjm92mswul2xnt22fk4t9v";
  cuttlefish = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDV2IDF4FP1T6qWcv+drtnbKyXkeB9kOAbU4wVWNfPSO";
  vaqita = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINYLME/00EUuEeTOSf2RaH30OGpXrRzsYNp404sWyxYm";
  leafsheep = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICII469nfANk6y6D8gd06OkmxBClpZsNXMW1kxDOreLX";
in
{
  "factorio/solrunners.age".publicKeys = [
    noa
    vaqita
    cuttlefish
  ];
  "github/flurry.age".publicKeys = [
    noa
    vaqita
    cuttlefish
  ];
  "github/nixconf.age".publicKeys = [
    noa
    vaqita
    cuttlefish
  ];
  "radicale/htpasswd.age".publicKeys = [
    noa
    vaqita
    cuttlefish
  ];
  "atticd/env.age".publicKeys = [
    noa
    cuttlefish
  ];
  "attic/anemone.age".publicKeys = [
    noa
    cuttlefish
    vaqita
    leafsheep
  ];
  "nifi/password.age".publicKeys = [
    noa
    vaqita
    cuttlefish
  ];
  "home-assistant/ns.age".publicKeys = [
    noa
    vaqita
    cuttlefish
  ];
  "discord/disqalculate.age".publicKeys = [
    noa
    vaqita
    cuttlefish
  ];
  "discord/shuttlefish.age".publicKeys = [
    noa
    cuttlefish
    leafsheep
  ];
  "netbird/config.yaml.age".publicKeys = [
    noa
    vaqita
    cuttlefish
  ];
  "netbird/dashboard.env.age".publicKeys = [
    noa
    vaqita
    cuttlefish
  ];
}
