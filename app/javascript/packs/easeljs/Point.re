type t = {
  .
  [@bs.set] "x": float,
  [@bs.set] "y": float,
};
type matrix2d = Matrix2D.t;

[@bs.module "@createjs/easeljs"] [@bs.new]
external create: (float, float) => t = "Point";

[@bs.send] external toString: (t, unit) => string = "toString";
[@bs.send] external clone: t => t = "clone";
[@bs.send]
external transformPoint: (matrix2d, float, float) => t = "transformPoint";

let isZero = (pt: t): bool => pt##x == 0.0 && pt##y == 0.0;

let add = (pt': t, pt: t): t => create(pt##x +. pt'##x, pt##y +. pt'##y);

let subtract = (pt': t, pt: t): t =>
  create(pt##x -. pt'##x, pt##y -. pt'##y);

let scale = (d: float, pt: t): t => create(pt##x *. d, pt##y *. d);

let apply = (mtx: matrix2d, pt: t): t => mtx->transformPoint(pt##x, pt##y);

let distanceTo = (dst: t, src: t): float =>
  (dst##x -. src##x) ** 2.0 +. (dst##y -. src##y) ** 2.0 |> sqrt;
