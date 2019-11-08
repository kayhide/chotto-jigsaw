type t;

[@bs.module "hammerjs"] [@bs.new]
external create: Webapi.Dom.Element.t => t = "default";
[@bs.module "hammerjs"] [@bs.val] external direction_all: 'a = "DIRECTION_ALL";
[@bs.send] external get: (t, string) => 'a = "get";
[@bs.send] external set: (t, 'a) => unit = "set";
[@bs.send] external add: (t, 'a) => unit = "add";
[@bs.send] external recognizeWith: (t, 'a) => unit = "recognizeWith";
[@bs.send] external on: (t, string, 'e => unit) => unit = "on";

module Pan = {
  [@bs.module "hammerjs"] [@bs.new] external create: 'a => 'b = "Pan";
};
module Rotate = {
  [@bs.module "hammerjs"] [@bs.new] external create: 'a => 'b = "Rotate";
};
