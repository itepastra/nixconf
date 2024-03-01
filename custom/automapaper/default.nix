{
	lib
	, stdenv
	, fetchgit
	, meson
	, ninja
	, pkg-config
	, pacman
	, libarchive
	, wayland
	, libGL
}:

stdenv.mkDerivation rec {
	pname = "automapaper";
	version = "unstable-2022-05-15";

	src = fetchgit {
		url = "https://github.com/itepastra/automapaper";
		rev = "f102526244d954a4e4ae30a4b11f070e821f66ec";
		sha256 = "sha256-IS9vqSmDbiLwLwUeIxxPI2t7yksxvACgiECeSV43Wug=";
	};

	meta = with lib; {
			description = "based animated wallpaper for wlroots";
			homepage = "https://github.com/itepastra/automapaper";
			license = licenses.gpl3Plus;
			platforms = platforms.linux;
			maintainers = with maintainers; [ itepastra ];
	};

	nativeBuildInputs = [
		meson
		ninja
		pkg-config
		pacman
		libarchive
	];
	buildInputs = [
		wayland
		libGL
	];

	configurePhase = ''
		meson setup build
	'';


	buildPhase = ''
		ninja -C build
	'';

	installPhase = ''
		mkdir -p $out/bin
		mv build/automapaper $out/bin
	'';
}
