{ overlays ? []
}@args:

let
  inherit (nixpkgs) pkgs lib;

  nodejs-overlay = self: super: {
    my-nodejs = self.nodejs-14_x;
    my-yarn = super.yarn.override {
      nodejs = self.my-nodejs;
    };
  };

  env-overlay = self: super: {
    my-env = super.buildEnv {
      name = "my-env";
      paths = with self; [
        docker-compose
        gnumake

        my-nodejs
        my-yarn
        purescript
        spago

        zlib
        ruby.devEnv

        postgresql_12
      ];
    };
  };

  nixpkgs = import <nixpkgs> (args // {
    overlays = overlays ++ [
      nodejs-overlay
      env-overlay
    ];
  });

in

pkgs.mkShell {
  buildInputs = with pkgs; [
    my-env
    zlib
    libiconv
  ];
}
