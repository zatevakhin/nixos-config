final: prev: let
  newVersion = "unstable-2025-07-19";
  newSrc = prev.fetchFromGitHub {
    owner = "yetone";
    repo = "avante.nvim";
    rev = "9ccf721435215e240c80b9b52d3723014600587f";
    hash = "sha256-o+p/5PL4q7SiBwTGsqef9x/6HG2EWqYa5heZ32DqJmM=";
  };

  avanteLibNew = prev.rustPlatform.buildRustPackage {
    pname = "avante-nvim-lib";
    version = newVersion;
    src = newSrc;

    useFetchCargoVendor = true;
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
              ln -s ${avanteLibNew}/lib/lib$n${ext} $out/build/lib$n${ext}
            fi
          done
        '';
      });
    };
}
