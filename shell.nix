{ overlays ? []
}@args:

let
  nixpkgs-src = builtins.fetchTarball {
    # master of 2020-11-21.
    url = "https://github.com/NixOS/nixpkgs/archive/2247d824fe07f16325596acc7faa286502faffd1.tar.gz";
    sha256 = "sha256:09jzdnsq7f276cfkmynqiaqg145k8z908rlr0170ld1sms1a83rw";
  };

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
        python # node-grpc

        zlib
        ruby.devEnv

        postgresql_12
      ];
    };
  };

  nixpkgs = import nixpkgs-src (args // {
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
