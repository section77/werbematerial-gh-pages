{ public-url ? "/" }:
let

  fetchNixpkgs = {rev, sha256}: builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs-channels/archive/${rev}.tar.gz";
    inherit sha256;
  };

  pkgs = import (fetchNixpkgs {
    rev = "8a9807f1941d046f120552b879cf54a94fca4b38";
    sha256 = "0s8gj8b7y1w53ak138f3hw1fvmk40hkpzgww96qrsgf490msk236";
  }) {};

  # nix-prefetch-git https://github.com/justinwoo/easy-purescript-nix
  easy-ps = import (pkgs.fetchFromGitHub {
    owner = "justinwoo";
    repo = "easy-purescript-nix";
    rev = "a09d4ff6a8e4a8a24b26f111c2a39d9ef7fed720";
    sha256 = "1iaid67vf8frsqfnw1vm313d50mdws9qg4bavrhfhmgjhcyqmb52";
  }) { inherit pkgs; };


  buildInputs =
    (with pkgs; [ dhall nodejs utillinux]) ++
    (with pkgs.nodePackages; [ parcel-bundler node2nix ]) ++
    (with easy-ps; [ purs spago spago2nix ]);

  werbematerial-gh-pages =
    let
      # nix-shell --run 'spago2nix generate'
      app = (import ./spago-packages.nix { inherit pkgs; }).mkBuildProjectOutput {
        src = pkgs.nix-gitignore.gitignoreSource [] ./.;
        purs = easy-ps.purs;
      };

      # nix-shell --run 'node2nix -c node_modules.nix --nodejs-12'
      node_modules = (import ./node_modules.nix { inherit pkgs; }).package;

    in pkgs.stdenv.mkDerivation rec {
      name = "werbematerial-gh-pages";
      version = "0.0.0";
      inherit buildInputs;
      src = pkgs.symlinkJoin {
        name = "src";
        paths = [
          "${app}"
          "${node_modules}/lib/node_modules/werbematerial-gh-pages"
        ];
      };
      phases = "buildPhase";
      buildPhase = ''
        mkdir -p $out
        cp -r ${src}/node_modules $out
        cp ${src}/index.html $out
        cp ${src}/webapp.js $out

        cp ${src}/indexer.js $out

        cp -r ${src}/output $out


        ls -ltr $out
      '';
    };

in if pkgs.lib.inNixShell then
  pkgs.mkShell {
    inherit buildInputs;
    shellHooks = ''
      alias serv="parcel serve --host 0.0.0.0 index.html"
    '';
  }
else {

  webapp = pkgs.runCommand "werbematerial-gh-pages-webapp" {
    inherit buildInputs;
  } ''
    mkdir $out
    parcel build --out-dir $out/ --public-url ${public-url} ${werbematerial-gh-pages}/index.html
  '';

  indexer = pkgs.runCommand "werbematerial-gh-pages-indexer" rec {
    inherit buildInputs;
  } ''
    mkdir $out
    parcel build --target node --out-dir $out ${werbematerial-gh-pages}/indexer.js

    cp ${pkgs.writeScript "indexer" ''
      ${pkgs.nodejs}/bin/node ./indexer.js $1 $2
    '' } $out/indexer
  '';
}
