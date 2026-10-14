{...}: {
  flake.nixosModules.llama-cpp = {
    lib,
    pkgs-unstable,
    ...
  }: {
    # EmbeddingGemma 2 support landed after the latest stable llama.cpp release.
    services.llama-cpp.package =
      (pkgs-unstable.llama-cpp.override {
        nodejs_latest = pkgs-unstable.nodejs_24;
      }).overrideAttrs (old: {
        version = "b11552";
        src = pkgs-unstable.fetchFromGitHub {
          owner = "ggml-org";
          repo = "llama.cpp";
          rev = "23b0202a189c44a54625aadcb37a946dd1d6278d";
          hash = "sha256-oISUD+czPe/RzXfCl0hyWxIbQnKFE37KwQmWdJwrHw8=";
        };
        npmDepsHash = "sha256-hqYzdp1FwPhYkBP278fQXgY9NCKB6Q3P6Gko7BfP0m0=";
        preConfigure = ''
          pushd tools/ui
          LLAMA_BUILD_NUMBER=11552 npm run build
          popd
        '';
        cmakeFlags =
          builtins.filter (flag:
            !(lib.hasPrefix "-DLLAMA_BUILD_NUMBER:" flag)
            && !(lib.hasPrefix "-DLLAMA_BUILD_COMMIT:" flag)
            && !(lib.hasPrefix "-DLLAMA_BUILD_IS_DEV:" flag))
          old.cmakeFlags
          ++ [
            "-DLLAMA_BUILD_NUMBER:STRING=11552"
            "-DLLAMA_BUILD_COMMIT:STRING=23b0202"
            "-DLLAMA_BUILD_IS_DEV:BOOL=TRUE"
          ];
      });
  };
}
