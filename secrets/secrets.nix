let
  noa = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKOiz4Dsp4fgtwgOvARzOO9kZI4fSwJ4QJCf34dGVB6Z";
in
{
  "restic/env.age".publicKeys = [ noa ];
  "restic/repo.age".publicKeys = [ noa ];
  "restic/password.age".publicKeys = [ noa ];
}

