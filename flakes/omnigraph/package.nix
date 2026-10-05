{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  gcc-unwrapped,
  symlinkJoin,
}: let
  version = "0.12.0";

  release =
    {
      x86_64-linux = {
        arch = "x86_64";
        hash = "sha256-7w4HcsmnTqiXm7RZ0vW47QDb0fLgbMcO7ZEGm6h8kYk=";
      };
      aarch64-linux = {
        arch = "arm64";
        hash = "sha256-L1TNnXUg8QqbSwx+iXT6LVF1yHFw8Ul0nUceliUOGmc=";
      };
    }.${
      stdenv.hostPlatform.system
    } or (throw "omnigraph: unsupported system ${stdenv.hostPlatform.system}");

  src = fetchurl {
    url = "https://github.com/ModernRelay/omnigraph/releases/download/v${version}/omnigraph-linux-${release.arch}.tar.gz";
    inherit (release) hash;
  };

  mkBinary = {
    pname,
    binary,
    description,
  }:
    stdenv.mkDerivation {
      inherit pname version src;
      sourceRoot = ".";
      nativeBuildInputs = [autoPatchelfHook];
      buildInputs = [gcc-unwrapped.lib];
      dontBuild = true;

      installPhase = ''
        runHook preInstall
        install -Dm755 ${binary} "$out/bin/${binary}"
        runHook postInstall
      '';

      meta = {
        inherit description;
        homepage = "https://github.com/ModernRelay/omnigraph";
        license = lib.licenses.mit;
        mainProgram = binary;
        platforms = ["x86_64-linux" "aarch64-linux"];
        sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      };
    };

  omnigraph-cli = mkBinary {
    pname = "omnigraph-cli";
    binary = "omnigraph";
    description = "CLI for the Omnigraph graph database";
  };

  omnigraph-server = mkBinary {
    pname = "omnigraph-server";
    binary = "omnigraph-server";
    description = "Omnigraph graph database server";
  };
in {
  inherit omnigraph-cli omnigraph-server;

  combined = symlinkJoin {
    name = "omnigraph-${version}";
    paths = [omnigraph-cli omnigraph-server];
    meta =
      omnigraph-cli.meta
      // {
        description = "Omnigraph CLI and server";
      };
  };
}
