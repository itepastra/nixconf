let
  noa = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKOiz4Dsp4fgtwgOvARzOO9kZI4fSwJ4QJCf34dGVB6Z";
  nuOS = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM79/rtDi2KIN75Rr6ae+A8lPTSCQfCkhbx1tGmQ3Qed";
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
