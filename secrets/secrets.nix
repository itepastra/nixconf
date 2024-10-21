let
  noa = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKOiz4Dsp4fgtwgOvARzOO9kZI4fSwJ4QJCf34dGVB6Z";
  nuOS = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM79/rtDi2KIN75Rr6ae+A8lPTSCQfCkhbx1tGmQ3Qed";
in
{
  "restic/env.age".publicKeys = [ noa ];
  "restic/repo.age".publicKeys = [ noa ];
  "restic/password.age".publicKeys = [ noa ];
  "github/flurry.age".publicKeys = [ nuOS ];
  "github/nixconf.age".publicKeys = [ nuOS ];
  "nix-serve/private.age".publicKeys = [ nuOS ];
}

