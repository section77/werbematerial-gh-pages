{ pkgs, purs }:
import (pkgs.fetchFromGitHub {
  owner = "jmackie";
  repo = "purescript.nix";
  rev = "8403f1512e945209f55d38b8f77e3a1a8256ae0d";
  sha256 = "0508m7r158k7j1vl28cpaxn4xp73dirqscl7rwblimjsxmw8srr9";
}) { inherit pkgs purs; }
