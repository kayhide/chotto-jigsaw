with import <nixpkgs> {};

pkgs.mkShell {
  buildInputs = with pkgs; [
    docker
    gnumake
    hivemind
    nodejs-13_x
    yarn
  ];
}
