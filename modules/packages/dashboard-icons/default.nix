{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "dashboard-icons";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "walkxcode";
    repo = "dashboard-icons";
    rev = "main";
    hash = "sha256-rKXeMAhHV0Ax7mVFyn6hIZXm5RFkbGakjugU0DG0jLM=";
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
    homepage = "https://github.com/walkxcode/dashboard-icons";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [];
  };
}
