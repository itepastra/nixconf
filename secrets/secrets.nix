let
  noa = "age1yubikey1qv9qr2l4srzpt9h9ess58hv4m58njxw50356vgjm92mswul2xnt22fk4t9v";
  cuttlefish = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDV2IDF4FP1T6qWcv+drtnbKyXkeB9kOAbU4wVWNfPSO";
  muOS = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINYLME/00EUuEeTOSf2RaH30OGpXrRzsYNp404sWyxYm";
  lambdaOS = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICII469nfANk6y6D8gd06OkmxBClpZsNXMW1kxDOreLX";
in
{
  "factorio/solrunners.age".publicKeys = [
    noa
    muOS
    cuttlefish
  ];
  "github/flurry.age".publicKeys = [
    noa
    muOS
    cuttlefish
  ];
  "github/nixconf.age".publicKeys = [
    noa
    muOS
    cuttlefish
  ];
  "radicale/htpasswd.age".publicKeys = [
    noa
    muOS
    cuttlefish
  ];
  "atticd/env.age".publicKeys = [
    noa
    cuttlefish
  ];
  "attic/anemone.age".publicKeys = [
    noa
    cuttlefish
    muOS
    lambdaOS
  ];
  "nifi/password.age".publicKeys = [
    noa
    muOS
    cuttlefish
  ];
  "home-assistant/ns.age".publicKeys = [
    noa
    muOS
    cuttlefish
  ];
  "discord/disqalculate.age".publicKeys = [
    noa
    muOS
    cuttlefish
  ];
  "discord/shuttlefish.age".publicKeys = [
    noa
    cuttlefish
    lambdaOS
  ];
  "netbird/config.yaml.age".publicKeys = [
    noa
    muOS
    cuttlefish
  ];
  "netbird/dashboard.env.age".publicKeys = [
    noa
    muOS
    cuttlefish
  ];
}
