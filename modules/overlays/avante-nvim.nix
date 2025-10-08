final: prev: let
  newVersion = "unstable-2025-09-29";
  newSrc = prev.fetchFromGitHub {
    owner = "yetone";
    repo = "avante.nvim";
    rev = "1947025ad3d6fddbaf7bee9e51bbadf1bc644e50";
    hash = "sha256-rhn7eC/Be5HjnKHJsH/ggFtIDcnkNw7htlPLPbLVHW4=";
  };

  avanteLibNew = prev.rustPlatform.buildRustPackage {
    pname = "avante-nvim-lib";
    version = newVersion;
    src = newSrc;

    cargoHash = "sha256-pTWCT2s820mjnfTscFnoSKC37RE7DAPKxP71QuM+JXQ=";

    nativeBuildInputs = [prev.pkg-config prev.makeWrapper prev.perl];
    buildInputs = [prev.openssl];
    buildFeatures = ["luajit"];

    checkFlags = [
      "--skip=test_hf"
      "--skip=test_public_url"
      "--skip=test_roundtrip"
      "--skip=test_fetch_md"
    ];
  };
in {
  avanteLibNew = avanteLibNew;

  vimPlugins =
    prev.vimPlugins
    // {
      avante-nvim = prev.vimPlugins.avante-nvim.overrideAttrs (old: let
        ext = prev.stdenv.hostPlatform.extensions.sharedLibrary;
      in {
        version = newVersion;
        src = newSrc;
        name = "vimplugin-avante.nvim-${newVersion}";

        passthru =
          (old.passthru or {})
          // {
            avante-nvim-lib = avanteLibNew;
            overlayMarker = "NEW-AVANTE";
          };

        postInstall = ''
          mkdir -p $out/build
          for n in avante_repo_map avante_templates avante_tokenizers avante_html2md; do
            if [ -f ${avanteLibNew}/lib/lib$n${ext} ]; then
              ln -s ${avanteLibNew}/lib/lib$n${ext} $out/build/$n${ext}
            fi
          done
        '';
      });
    };
}
