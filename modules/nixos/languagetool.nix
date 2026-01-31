{pkgs, ...}: let
  ngrams = pkgs.linkFarm "languagetool-ngrams" {
    en = pkgs.fetchzip {
      url = "https://languagetool.org/download/ngram-data/ngrams-en-20150817.zip";
      hash = "sha256-v3Ym6CBJftQCY5FuY6s5ziFvHKAyYD3fTHr99i6N8sE=";
    };
  };
in {
  services.languagetool = {
    enable = true;
    settings = {
      # Important for good language auto-detection
      # (without fastText, auto-detection quality is noticeably worse)
      fasttextBinary = "${pkgs.fasttext}/bin/fasttext";

      # Main language identification model (~126 MB)
      fasttextModel = pkgs.fetchurl {
        url = "https://dl.fbaipublicfiles.com/fasttext/supervised-models/lid.176.bin";
        hash = "sha256-fmnsVFG8JhzHhE5J5HkqhdfwnAZ4nsgA/EpErsNidk4=";
      };

      languageModel = ngrams;
    };
  };
}
