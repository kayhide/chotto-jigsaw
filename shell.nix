with import ./. {};

pkgs.mkShell {
  buildInputs = with pkgs; [
    docker-compose
    gnumake

    nodejs
    yarn
    purescript
    spago

    libiconv
    zlib
    ruby_2_6

    postgresql_12
  ];
}
