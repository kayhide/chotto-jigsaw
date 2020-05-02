with import ./. {};

pkgs.mkShell {
  buildInputs = with pkgs; [
    hivemind
    libiconv
    nodejs
    postgresql_12
    purescript
    ruby_2_6
    spago
    yarn
    zlib
  ];
}
