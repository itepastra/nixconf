let
  noa = "AGE-PLUGIN-YUBIKEY-1Q93MKQVZSJ733PC0VWRVC";
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
  "restic/env.age".publicKeys = [ noa ];
  "restic/repo.age".publicKeys = [ noa ];
  "restic/password.age".publicKeys = [ noa ];
  "github/flurry.age".publicKeys = [
    noa
    muOS
    nuOS
  ];
  "github/anstml.age".publicKeys = [
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
  "authentik/env.age".publicKeys = [
    noa
    muOS
    nuOS
  ];
  "wg/muos.age".publicKeys = [
    muOS
  ];
  "zitadel/master.age".publicKeys = [
    noa
    lambdaOS
    nuOS
  ];
}
