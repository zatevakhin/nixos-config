{
  lib,
  fetchFromGitHub,
  rustPlatform,
  installShellFiles,
}:
rustPlatform.buildRustPackage rec {
  pname = "rusmux";
  version = "0.8.0";
  src = fetchFromGitHub {
    owner = "MeirKriheli";
    repo = "rusmux";
    rev = "v${version}";
    hash = "sha256-hHdZwvvoPppPdlYwUrg73yAPXlq1w8iH/sAlr8mshNw=";
  };

  cargoHash = "sha256-Ve0mv3aSdPCNruy/OgL/+xGrWC3Uu65BQWD43PJBW5Q=";

  nativeBuildInputs = [installShellFiles];

  meta = with lib; {
    description = "A Rust-based tmux session manager";
    homepage = "https://github.com/MeirKriheli/rusmux";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
