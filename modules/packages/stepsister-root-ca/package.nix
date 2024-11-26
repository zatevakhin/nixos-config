{ lib, stdenv, fetchurl, openssl }:

stdenv.mkDerivation rec {
  name = "stepsister-root-ca";
  version = "1.0.1";

  src = fetchurl {
    url = "https://ca.homeworld.lan:8443/roots.pem";
    hash = "sha256-+EsQqEb+jaLKq4/TOUTEwF/9lwU5mETu4MY4GTN1V+A=";
    curlOpts = "--insecure";
  };

  nativeBuildInputs = [ openssl ];

  dontUnpack = true;
  dontBuild = true;

  preInstall = ''
    echo "Verifying certificate fingerprint..."
    CERT_FINGERPRINT=$(openssl x509 -noout -fingerprint -sha256 -in $src | cut -d= -f2 | tr -d ':' | tr '[:upper:]' '[:lower:]')
    EXPECTED_FINGERPRINT="295b225084a9a421b5c9190cd3347467bb722b72efb19052bb8dea895081e0db"

    if [ "$CERT_FINGERPRINT" != "$EXPECTED_FINGERPRINT" ]; then
      echo "Certificate fingerprint verification failed!"
      echo "Expected: $EXPECTED_FINGERPRINT"
      echo "Got:      $CERT_FINGERPRINT"
      exit 1
    fi
    echo "Certificate fingerprint verified successfully!"
  '';

  installPhase = ''
    mkdir -p $out/etc/ssl/certs
    cp $src $out/etc/ssl/certs/${name}.pem
  '';

  meta = with lib; {
    description = "Root CA certificate for my local network.";
    license = licenses.unfree;
    platforms = platforms.all;
    maintainers = [];
  };
}

