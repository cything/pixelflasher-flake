{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.

        packages.default = with pkgs; python3Packages.buildPythonApplication rec {
          pname = "pixelflasher";
          version = "7.10.0.0";
          format = "setuptools";

          src = fetchFromGitHub {
             owner = "badabing2005";
             repo = "PixelFlasher";
             tag = "v${version}";
             hash = "sha256-7gDTPbf+kaF8c4G+Vl8Vyzv2TdMzzNhWW6V6xUdGtBU=";
          };

          dependencies = with python3Packages; [
            attrdict
            httplib2
            platformdirs
            requests
            darkdetect
            markdown
            pyperclip
            protobuf4
            six
            bsdiff4
            lz4
            psutil
            json5
            beautifulsoup4
            chardet
            cryptography
            rsa
            wxpython
          ];

          nativeBuildInputs = [
            wrapGAppsHook
            python3Packages.pyinstaller
          ];

          buildPhase = ''
            runHook preBuild
            pyinstaller --clean --noconfirm build-on-linux.spec
          '';

          installPhase = ''
            runHook preInstall
            
            mkdir -p $out/bin
            cp dist/PixelFlasher $out/bin
            
            runHook postInstall
          '';
        };
      };
    };
}
