{ fetchFromGitHub
, stdenv
, lib
}:

stdenv.mkDerivation rec {
  pname = "swaynagmode";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "b0o";
    repo = "swaynagmode";
    rev = "v${version}";
    sha256 = "BuPnP9PerPpxi0DJgp0Cfkaddi8QAYzcvbDTiMehkJw=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp swaynagmode $out/bin
  '';

  meta = with lib; {
    description = "A wrapper script which provides programmatic control over swaynag, intended for use with keyboard bindings.";
    homepage = "https://github.com/b0o/swaynagmode";
    license = licenses.gpl3;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
