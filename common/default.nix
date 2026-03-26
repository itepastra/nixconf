configSettings:
{ ... }:
{
  imports = [
    ./locale.nix
    ./boot.nix
    ./substitutors.nix
    ((import ./configuration.nix) configSettings)
  ];
}
