{
  lib,
  appimageTools,
  fetchurl,
}:
let
  version = "4.7.1";
  pname = "reticulum-meshchatx";

  src = fetchurl {
    url = "https://github.com/Quad4-Software/MeshChatX/releases/download/v${version}/ReticulumMeshChatX-v${version}-linux-x86_64.AppImage";
    hash = "sha256-lxJctHYgz8AmAnwLkwFg8/ia92BF0Pmy1WRdFMnpH3g=";
  };

  appimageContents = appimageTools.extractType1 { inherit pname src; };
in
appimageTools.wrapType2 rec {
  inherit pname version src;

  meta = {
    description = "Comminucation client for reticulum";
    homepage = "https://meshchatx.com/";
    downloadPage = "https://meshchatx.com/download";
    license = lib.licenses.bsd0;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ onny ];
    platforms = [ "x86_64-linux" ];
  };
}
