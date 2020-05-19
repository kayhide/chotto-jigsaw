{}:

let
  # The last snapshot which has ruby-2.6.5
  nixpkgs-20200401 = import (builtins.fetchTarball {
    name = "nixos-unstable-2020-04-01";
    url = https://github.com/nixos/nixpkgs/archive/4e3958fff88d0d725edf097f9920709ede280811.tar.gz;
    sha256 = "1w7qn4pjgnq04g79w6iq1h4zgc7vjalwsidrwlsrwnzq9h8d9iai";
  }) {};

  rubyOverlay = self: super: {
    ruby_2_6 = nixpkgs-20200401.ruby_2_6;
  };

  nodejsOverlay = self: super: {
    nodejs = super.nodejs-13_x;
    yarn = super.yarn // {
      buildInputs = [ self.nodejs ];
    };
  };

in

import <nixpkgs> {
  overlays = [
    rubyOverlay
    nodejsOverlay
  ];
}
