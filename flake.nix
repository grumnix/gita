{
  description = "A command-line tool to manage multiple git repos";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    gita-src.url = "github:nosarthur/gita?ref=v0.16.6.1";
    gita-src.flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, gita-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages = rec {
          default = gita;

          gita = pkgs.python3Packages.buildPythonPackage rec {
            pname = "gita";
            version = "0.16.3";

            src = gita-src;

            pyproject = true;
            build-system = [ pkgs.python3Packages.setuptools ];

            postUnpack = ''
              substituteInPlace source/tests/test_main.py \
                --replace '"gita"' '"source"' \
                --replace '"gita\n"' '"source\n"' \
               --replace '"group add gita' '"group add source'
            '';

            checkPhase = ''
               git init
               pytest tests
            '';

            postInstall = ''
              installShellCompletion --bash --name gita ${src}/.gita-completion.bash
              installShellCompletion --zsh --name gita ${src}/.gita-completion.zsh
            '';

            propagatedBuildInputs = with pkgs; [
              python3Packages.pyyaml
              python3Packages.setuptools
            ];

            nativeBuildInputs = with pkgs; [
              installShellFiles

              # FIXME: should be checkInputs
              git
              python3Packages.pytest
            ];

            meta = with pkgs.lib; {
              homepage = "https://github.com/nosarthur/gita";
              license = licenses.mit;
            };
          };
        };
      }
    );
}
