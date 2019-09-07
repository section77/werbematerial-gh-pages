{ pkgs }:
import (pkgs.fetchFromGitHub {
  owner = "justinwoo";
  repo = "easy-purescript-nix";
  rev = "a3b1c569a0c483fc3179762633fba804f604416c";
  sha256 = "10ncghljr1bdcxwr53mn0knnjpnp4g42zgnij214l5nj8mj631a4";
}) { inherit pkgs; }

