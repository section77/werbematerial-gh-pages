{ pkgs ? (import (builtins.fetchTarball {
           name = "nixos-unstable";

           # git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable
           url = "https://github.com/nixos/nixpkgs/archive/7d5375ebf4cd417465327d7ab453687fd19663c9.tar.gz";

           # nix-prefetch-url --unpack https://github.com/nixos/nixpkgs/archive/7d5375ebf4cd417465327d7ab453687fd19663c9.tar.gz
           sha256 = "18myjqws6mm4xsx4nx348yix793wyk76dyklls6dgyp9rg0gfcma";
         }) {})
, ps-package-sets ? "psc-0.13.3"
, ps-package-sets-sha256 ? "15islja5761d7w1k1gaj6xj0pzgs306qrxxyqh6ppw6569vq3y3p"
, public-url ? "/"
 }:
let

  easy-ps = pkgs.callPackage ./nix/easy-ps.nix { };

  purescript = pkgs.callPackage ./nix/purescript.nix { inherit (easy-ps) purs; };

  package-set = purescript.loadPackageSet {
    url = "https://github.com/purescript/package-sets";
    rev = ps-package-sets;
    sha256 = ps-package-sets-sha256;
  };

  werbematerial-gh-pages = purescript.compile {
    name = "werbematerial-gh-pages";
    src = pkgs.nix-gitignore.gitignoreSource [] ./. ;
    srcDirs = ["src"];

    dependencies = [
      "affjax"
      "prelude"
      "console"
      "react-basic"
      "foreign-generic"
      "foreign-object"
      "node-fs"
      "node-process"
      "test-unit"
      "debug"
    ];

    inherit package-set;
  };

  # to change npm dependencies:
  #   - edit ./nix/node-modules/node-packages.json
  #   - run: nix-shell -p nodePackages.node2nix --run 'cd nix/node-modules; node2nix --nodejs-10 -i node-packages.json'
  #   - add the dependency to the 'paths' array below
  nodeModules = with (import ./nix/node-modules { });
  pkgs.symlinkJoin {
    name = "node-modules";
    paths = [
      "${react}/lib/node_modules"
      "${react}/lib/node_modules/react/node_modules"
      "${react-dom}/lib/node_modules"
      "${react-dom}/lib/node_modules/react-dom/node_modules"
      "${materialize-css}/lib/node_modules"
      "${cssnano}/lib/node_modules"
    ];
  };

in if pkgs.lib.inNixShell then
  pkgs.mkShell {
    buildInputs = with pkgs; [
      easy-ps.purs
      easy-ps.spago
      nodejs
      nodePackages.parcel-bundler
    ];

    shellHooks = ''
      alias serv="parcel serve --host 0.0.0.0 index.html"
    '';
  }
else {

  webapp = pkgs.runCommand "werbematerial-gh-pages-webapp" {
    buildInputs = [pkgs.nodePackages.parcel-bundler];
  } ''
    mkdir $out

    ln -s ${nodeModules} node_modules
    ln -s ${werbematerial-gh-pages} output

    cp ${werbematerial-gh-pages.src}/index.html .
    cp ${werbematerial-gh-pages.src}/webapp.js .

    parcel build --public-url ${public-url} --out-dir $out index.html
  '';

  indexer = pkgs.runCommand "werbematerial-gh-pages-indexer" rec {
    buildInputs = [pkgs.nodePackages.parcel-bundler];
  } ''
    mkdir $out

    ln -s ${nodeModules} node_modules
    ln -s ${werbematerial-gh-pages} output

    cp ${werbematerial-gh-pages.src}/indexer.js .

    parcel build --target node --out-dir $out indexer.js

    cp ${pkgs.writeScript "indexer" ''
      ${pkgs.nodejs}/bin/node ./indexer.js $1 $2
    '' } $out/indexer
  '';
}
