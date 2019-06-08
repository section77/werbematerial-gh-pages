{ pkgs, purs }:
import (pkgs.fetchFromGitHub {
  owner = "jmackie";
  repo = "purescript-nix";
  rev = "f3f8cb1191e988a87bf045760f2cd95cb51f9561";
  sha256 = "0lpvxlpm3ikbmc8f8azv8nc5l59q9qczzq5ry2ksnk7jgbsny6fj";
}) { inherit pkgs purs; }
