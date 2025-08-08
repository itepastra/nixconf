{
  pkgs,
  ...
}:
pkgs.stdenv.mkDerivation rec {
  pname = "vvvvvv-ap";
  version = "0.5.1-2";

  src = pkgs.fetchFromGitHub {
    owner = "N00byKing";
    repo = "VVVVVV";
    rev = "AP0.5.1-2";
    fetchSubmodules = true;
    hash = "sha256-v7V/1HgT+jYjzbasvoZbJRylC3HjdWeJVtdP1Bsh5bs=";
  };
  sourceRoot = "${src.name}/desktop_version";

  # data.zip is non-redistributable, so we require the user to provide it themselves
  src-data = pkgs.requireFile {
    name = "data.zip";
    url = "your copy of the game";
    sha256 = "1q2pzscrglmwfgdl8yj300wymwskh51iq66l4xcd0qk0q3g3rbkg";
  };

  nativeBuildInputs = with pkgs; [ cmake ];
  buildInputs = with pkgs; [
    openssl
    SDL2
  ];

  # fix the lack of an executable getting created
  patchPhase = ''
    echo '
    if(TARGET VVVVVV)
      install(TARGETS VVVVVV RUNTIME DESTINATION bin)
    endif()
    ' >> CMakeLists.txt
  '';

  postInstall = ''
    cp "${src-data}" "$out/bin/"
  '';

  preFixup = ''
    substituteInPlace $out/lib/pkgconfig/zlib.pc \
      --replace-fail 'sharedlibdir=''${exec_prefix}//' 'sharedlibdir=' \
      --replace-fail 'libdir=''${exec_prefix}//' 'libdir=' \
      --replace-fail 'includedir=''${exec_prefix}//' 'includedir='
  '';

  enableParallelBuilding = true;

  meta = {
    mainProgram = "VVVVVV";
  };
}
