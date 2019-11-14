type t;

[@bs.module "@createjs/easeljs"] [@bs.new]
external create: unit => t = "Matrix2D";
[@bs.send] external toString: (t, unit) => string = "toString";
[@bs.send] external translate: (t, float, float) => t = "translate";
[@bs.send] external rotate: (t, float) => t = "rotate";
[@bs.send] external scale: (t, float, float) => t = "scale";
[@bs.send] external invert: t => t = "invert";
[@bs.send] external decompose: (t, unit) => 'obj = "decompose";
[@bs.send]
external appendTransform: (t, float, float, float, float, float) => t =
  "appendTransform";
