{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "dashboard-icons";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "homarr-labs";
    repo = "dashboard-icons";
    rev = "9c59ee602f74b9848434813f5870cd0bab23d117";
    hash = "sha256-PLcaGQqphMTlSzcOaNrRNtOpXmk1BnCJqBjWSNcSbXo=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/dashboard-icons
    cp -r svg $out/share/dashboard-icons/
    cp -r png $out/share/dashboard-icons/

    runHook postInstall
  '';

  meta = with lib; {
    description = "A collection of dashboard icons for various applications and services";
    homepage = "https://github.com/homarr-labs/dashboard-icons";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [];
  };
}
