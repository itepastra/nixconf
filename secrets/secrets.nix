let
  noa = "age1yubikey1qv9qr2l4srzpt9h9ess58hv4m58njxw50356vgjm92mswul2xnt22fk4t9v";
  nuOS = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDV2IDF4FP1T6qWcv+drtnbKyXkeB9kOAbU4wVWNfPSO";
  muOS = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHw47VIyrawkRLzYKgbd0P6DLDyVvwHfVb5DBPPQUG+d";
  lambdaOS = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICII469nfANk6y6D8gd06OkmxBClpZsNXMW1kxDOreLX";
in
{
  "factorio/solrunners.age".publicKeys = [
    noa
    muOS
    nuOS
  ];
  "github/flurry.age".publicKeys = [
    noa
    muOS
    nuOS
  ];
  "github/nixconf.age".publicKeys = [
    noa
    muOS
    nuOS
  ];
  "radicale/htpasswd.age".publicKeys = [
    noa
    muOS
    nuOS
  ];
  "nifi/password.age".publicKeys = [
    noa
    muOS
    nuOS
  ];
  "home-assistant/ns.age".publicKeys = [
    noa
    muOS
    nuOS
  ];
  "discord/disqalculate.age".publicKeys = [
    noa
    muOS
    nuOS
  ];
  "wg/muos.age".publicKeys = [
    noa
    muOS
  ];
  "wg/nuos.age".publicKeys = [
    noa
    nuOS
  ];
  "wg/lambdaos.age".publicKeys = [
    noa
    lambdaOS
  ];
}
