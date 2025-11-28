{
  description = "A command-line tool to manage multiple git repos";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    gita_src.url = "github:nosarthur/gita?ref=v0.16.8.2";
    gita_src.flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, gita_src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages = rec {
          default = gita;

          gita = pkgs.python3Packages.buildPythonPackage rec {
            pname = "gita";
            version = "0.16.8.2";

            src = gita_src;

            pyproject = true;
            build-system = [ pkgs.python3Packages.setuptools ];

            postUnpack = ''
              substituteInPlace source/tests/test_main.py \
                --replace '"gita"' '"source"' \
                --replace '"gita\n"' '"source\n"' \
                --replace '"group add gita' '"group add source'
            '';

            checkPhase = ''
               # workaround for "Permission denied: '/homeless-shelter'"
               export HOME=$TMPDIR

               git init
               pytest tests
            '';

            postInstall = ''
              installShellCompletion --bash --name gita ${src}/auto-completion/bash/.gita-completion.bash
              installShellCompletion --fish --name gita ${src}/auto-completion/fish/gita.fish
              installShellCompletion --zsh  --name gita ${src}/auto-completion/zsh/.gita-completion.zsh
            '';

            nativeCheckInputs = with pkgs; [
              git
              python3Packages.pytest
            ];

            nativeBuildInputs = with pkgs; [
              installShellFiles
            ];

            propagatedBuildInputs = with pkgs; [
              python3Packages.argcomplete
              python3Packages.pyyaml
              python3Packages.setuptools
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
