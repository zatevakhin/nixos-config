final: prev: let
  newVersion = "unstable-2025-07-19";
  newSrc = prev.fetchFromGitHub {
    owner = "yetone";
    repo = "avante.nvim";
    rev = "5a4ed4ac924adb148075b461016078ac18792816";
    hash = "sha256-X6pecjj1TtXQMzSr8fe2nRGcCmbFQ6XeY423JbKNt0s=";
  };

  avanteLibNew = prev.rustPlatform.buildRustPackage {
    pname = "avante-nvim-lib";
    version = newVersion;
    src = newSrc;

    cargoHash = "sha256-8mBpzndz34RrmhJYezd4hLrJyhVL4S4IHK3plaue1k8=";

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
