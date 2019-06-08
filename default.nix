{ pkgs ? import <nixpkgs> { }, purs ? "v0.12.5"
, ps-package-sets ? "psc-0.12.5-20190525" }:
let

  easy-ps = pkgs.callPackage ./nix/easy-ps.nix { };
  ps-nix = pkgs.callPackage ./nix/purescript-nix.nix { inherit purs; };

  werbematerial-gh-pages = ps-nix.compile {
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

    package-set = ps-nix.package-sets."${ps-package-sets}";
  };

  # to change npm dependencies:
  #   - edit ./nix/node-modules/node-packages.json
  #   - run (cd nix/node-modules; nix-shell -p nodePackages.node2nix --run 'node2nix -8 -i node-packages.json')
  #   - add the dependency to the 'paths' array below
  nodeModules = with (import ./nix/node-modules { });
  pkgs.symlinkJoin {
    name = "node-modules";
    paths = [
      "${react}/lib/node_modules"
      "${react}/lib/node_modules/react/node_modules"
      "${react-dom}/lib/node_modules"
      "${react-dom}/lib/node_modules/react-dom/node_modules"
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
      alias serv="parcel index.html"
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

    parcel build --out-dir $out index.html
  '';

  indexer = pkgs.runCommand "werbematerial-gh-pages-indexer" {
    buildInputs = [pkgs.nodePackages.parcel-bundler];
  } ''
    mkdir $out

    ln -s ${nodeModules} node_modules
    ln -s ${werbematerial-gh-pages} output

    cp ${werbematerial-gh-pages.src}/indexer.js .

    parcel build --target node --out-dir $out indexer.js
  '';
}
