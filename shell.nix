with import <nixpkgs> {};

stdenv.mkDerivation rec {
  pname = "chotto-jigsaw-shell";
  version = "0.1.0";
  buildInputs = with pkgs; [
    docker
    gnumake
    hivemind
    nodejs
    yarn
  ];
}
