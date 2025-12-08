let
  noa = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKOiz4Dsp4fgtwgOvARzOO9kZI4fSwJ4QJCf34dGVB6Z";
  nuOS = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDV2IDF4FP1T6qWcv+drtnbKyXkeB9kOAbU4wVWNfPSO";
  muOS = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMD1SQumqEsx1N0v35ThrGgb9rH12j/eOIUf3TdEi0G6";
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
}
