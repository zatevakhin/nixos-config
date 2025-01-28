{pkgs, ...}: {
  nixpkgs.overlays = [
    (self: super: {
      open-interpreter = super.open-interpreter.overridePythonAttrs (old: rec {
        version = "0.4.2";
        src = super.fetchFromGitHub {
          owner = "KillianLucas";
          repo = "open-interpreter";
          rev = "v${version}";
          sha256 = "sha256-fogCcWAhcrCrrcV0q4oKttkf/GeJaJSZnbgiFxvySs8=";
        };

        dependencies =
          (old.dependencies or [])
          ++ [
            (super.python3Packages.anthropic.overridePythonAttrs (oldAttrs: rec {
              version = "0.37.1";
              src = super.fetchFromGitHub {
                owner = "anthropics";
                repo = "anthropic-sdk-python";
                rev = "v${version}";
                sha256 = "sha256-f6CYNZFOF0gNxdsnIjKZLNurYyAiwbYHI6uP0Xu0d6M=";
              };
            }))
            (super.python3Packages.starlette.overridePythonAttrs (oldAttrs: rec {
              version = "0.37.2";
              src = super.python3Packages.fetchPypi {
                pname = "starlette";
                inherit version;
                sha256 = "sha256-mviQKQEzt5/D21VHSt4g9iIKNkoEAuC1VufNXh4JOCM=";
              };
            }))
            super.python3Packages.html2text
            super.python3Packages.selenium
            super.python3Packages.typer
            super.python3Packages.webdriver-manager
            super.python3Packages.pyautogui
          ];
      });
    })
  ];

  environment.systemPackages = with pkgs; [
    open-interpreter
  ];
}
