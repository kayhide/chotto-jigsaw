type point = {
  .
  [@bs.set] "x": float,
  [@bs.set] "y": float,
};
type matrix2d = Matrix2D.matrix2d;

[@bs.module "@createjs/easeljs"] [@bs.new]
external create: (float, float) => point = "Point";

[@bs.send] external toString: (point, unit) => string = "toString";
[@bs.send] external clone: point => point = "clone";
[@bs.send]
external transformPoint: (matrix2d, float, float) => point = "transformPoint";

let isZero = (pt: point): bool => pt##x == 0.0 && pt##y == 0.0;

let add = (pt': point, pt: point): point =>
  create(pt##x +. pt'##x, pt##y +. pt'##y);

let subtract = (pt': point, pt: point): point =>
  create(pt##x -. pt'##x, pt##y -. pt'##y);

let scale = (d: float, pt: point): point => create(pt##x *. d, pt##y *. d);

let apply = (mtx: matrix2d, pt: point): point =>
  mtx->transformPoint(pt##x, pt##y);

let distanceTo = (dst: point, src: point): float =>
  (dst##x -. src##x) ** 2.0 +. (dst##y -. src##y) ** 2.0 |> sqrt;
