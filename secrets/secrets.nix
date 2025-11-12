let
  noa = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKOiz4Dsp4fgtwgOvARzOO9kZI4fSwJ4QJCf34dGVB6Z";
  nuOS = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMD1SQumqEsx1N0v35ThrGgb9rH12j/eOIUf3TdEi0G6";
in
{
  "factorio/solrunners.age".publicKeys = [
    noa
    nuOS
  ];
  "restic/env.age".publicKeys = [ noa ];
  "restic/repo.age".publicKeys = [ noa ];
  "restic/password.age".publicKeys = [ noa ];
  "github/flurry.age".publicKeys = [
    noa
    nuOS
  ];
  "github/anstml.age".publicKeys = [
    noa
    nuOS
  ];
  "github/nixconf.age".publicKeys = [
    noa
    nuOS
  ];
  "nix-serve/private.age".publicKeys = [
    noa
    nuOS
  ];
  "radicale/htpasswd.age".publicKeys = [
    noa
    nuOS
  ];
  "nifi/password.age".publicKeys = [
    noa
    nuOS
  ];
  "home-assistant/ns.age".publicKeys = [
    noa
    nuOS
  ];
  "discord/disqalculate.age".publicKeys = [
    noa
    nuOS
  ];
  "authentik/env.age".publicKeys = [
    noa
    nuOS
  ];
}
