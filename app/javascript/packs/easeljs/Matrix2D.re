type matrix2d;

[@bs.module "@createjs/easeljs"] [@bs.new]
external create: unit => matrix2d = "Matrix2D";
[@bs.send] external toString: (matrix2d, unit) => string = "toString";
[@bs.send]
external translate: (matrix2d, float, float) => matrix2d = "translate";
[@bs.send] external rotate: (matrix2d, float) => matrix2d = "rotate";
[@bs.send] external scale: (matrix2d, float, float) => matrix2d = "scale";
[@bs.send] external invert: matrix2d => matrix2d = "invert";
[@bs.send] external decompose: (matrix2d, unit) => 'obj = "decompose";
[@bs.send]
external appendTransform:
  (matrix2d, float, float, float, float, float) => matrix2d =
  "appendTransform";
