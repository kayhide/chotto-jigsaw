type t = {
  .
  [@bs.set] "x": float,
  [@bs.set] "y": float,
  [@bs.set] "width": float,
  [@bs.set] "height": float,
  [@bs.set] "empty": bool,
};

[@bs.module "@createjs/easeljs"] [@bs.new]
external create: (float, float, float, float) => t = "Rectangle";

[@bs.send] external toString: (t, unit) => string = "toString";

let topLeft = (rect: t): Point.t => Point.create(rect##x, rect##y);

let topRight = (rect: t): Point.t =>
  Point.create(rect##x +. rect##width, rect##y);

let bottomLeft = (rect: t): Point.t =>
  Point.create(rect##x, rect##y +. rect##height);

let bottomRight = (rect: t): Point.t =>
  Point.create(rect##x +. rect##width, rect##y +. rect##height);

let center = (rect: t): Point.t =>
  Point.create(rect##x +. rect##width /. 2.0, rect##y +. rect##height /. 2.0);

let cornerPoints = (rect: t): list(Point.t) => [
  rect |> topLeft,
  rect |> topRight,
  rect |> bottomLeft,
  rect |> bottomRight,
];

let empty = (): t => {
  let rect = create(0.0, 0.0, 0.0, 0.0);
  rect##empty #= true;
  rect;
};

let clear = (rect: t): t => {
  rect##empty #= true;
  rect;
};

let addPoint = (rect: t, pt: Point.t): t => {
  if (rect##empty) {
    rect##x #= pt##x;
    rect##y #= pt##y;
    rect##width #= 0.0;
    rect##height #= 0.0;
    rect##empty #= false;
  } else {
    switch (pt##x < rect##x, rect##x +. rect##width < pt##x) {
    | (true, _) =>
      rect##width #= (rect##width +. rect##x -. pt##x);
      rect##x #= pt##x;
      ();
    | (_, true) =>
      rect##width #= (pt##x -. rect##x);
      ();
    | _ => ()
    };
    switch (pt##y < rect##y, rect##y +. rect##height < pt##y) {
    | (true, _) =>
      rect##height #= (rect##height +. rect##y -. pt##y);
      rect##y #= pt##y;
      ();
    | (_, true) =>
      rect##height #= (pt##y -. rect##y);
      ();
    | _ => ()
    };
  };
  rect;
};

let addRectangle = (rect': t, rect: t): t =>
  rect' |> cornerPoints |> List.fold_left(addPoint, rect);

let fromPoints = (points: list(Point.t)): t =>
  points |> List.fold_left(addPoint, empty());

let inflate = (offset: float, rect: t): t => {
  rect##x #= (rect##x -. offset);
  rect##y #= (rect##y -. offset);
  rect##width #= (rect##width +. offset *. 2.0);
  rect##height #= (rect##height +. offset *. 2.0);
  rect;
};
