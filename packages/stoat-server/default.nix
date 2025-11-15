{
  pkgs,
  ...
}:
pkgs.rustPlatform.buildRustPackage {
  name = "stoatchat";
  version = "0.8.8-1";

  src = pkgs.fetchFromGitHub {
    owner = "stoatchat";
    repo = "stoatchat";
    tag = "20250807-1";
    hash = "sha256-HrhucXy6NywgH7iPEfR28mwp6qEmCXIGBcKBSEzOCsY=";
  };

  nativeBuildInputs = with pkgs; [
    pkg-config
  ];

  buildInputs = with pkgs; [
    openssl
  ];

  cargoHash = "sha256-inlB/U97XKjLbX0nPyu/ddLvPiZEET3pOYm6R+tJeSM=";

  meta = {
    description = "Open source discord alternative";
    homepage = "https://stoat.chat/";
  };
}
