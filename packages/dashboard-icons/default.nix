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
    rev = "d84d00eef4b14084963d5996397b76f9fe22f0c7";
    hash = "sha256-E28L0w19cKvuLsz86gLpUOFtnsqx8/K8dMtg3ph7ehk=";
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
