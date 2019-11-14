type point = Point.t;
type graphics = Graphics.t;
type puzzle = Puzzle.t;
type piece = Piece.t;

type t = {
  puzzle,
  drawsImage: bool,
  drawsStroke: bool,
  drawsControlLine: bool,
  drawsBoundary: bool,
  drawsCenter: bool,
};

let create = (puzzle: puzzle): t => {
  puzzle,
  drawsImage: true,
  drawsStroke: false,
  drawsControlLine: false,
  drawsBoundary: false,
  drawsCenter: false,
};

let image = (drawer: t): 'a => drawer.puzzle.image;

let drawHitArea = (piece: piece, g: graphics): unit => {
  open Graphics;
  let rect' = piece |> Piece.localBoundary;
  let _ =
    g
    ->beginFill("#000")
    ->drawRect(rect'##x, rect'##y, rect'##width, rect'##height);
  ();
};

let drawCurve = (points: Piece.loop, g: graphics): unit => {
  open Graphics;
  switch (points |> List.hd) {
  | Some(pt1) =>
    let _ = g->moveTo(pt1##x, pt1##y);
    ();
  | _ => ()
  };

  let rec f = xs =>
    switch (xs) {
    | [Some(pt1), Some(pt2), Some(pt3), ...pts] =>
      let _ =
        g->bezierCurveTo(pt1##x, pt1##y, pt2##x, pt2##y, pt3##x, pt3##y);
      pts |> f;
    | [_, _, Some(pt3), ...pts] =>
      let _ = g->lineTo(pt3##x, pt3##y);
      pts |> f;
    | _ => ()
    };
  points |> List.tl |> f;
};

let drawPolyline = (points: Piece.loop, g: graphics): unit => {
  open Graphics;
  switch (points |> List.hd) {
  | Some(pt1) =>
    let _ = g->moveTo(pt1##x, pt1##y);
    ();
  | _ => ()
  };

  let rec f = xs =>
    switch (xs) {
    | [Some(pt1), ...pts] =>
      let _ = g->lineTo(pt1##x, pt1##y);
      pts |> f;
    | _ => ()
    };
  points |> List.tl |> f;
};

let draw = (piece: piece, g: graphics, drawer: t): unit => {
  open Graphics;
  g->clear();
  if (drawer.drawsImage) {
    let _ = g->beginBitmapFill(drawer |> image);
    ();
  } else {
    let _ = g->beginFill("#9fa");
    ();
  };
  if (drawer.drawsStroke) {
    let _ = g->setStrokeStyle(2.0)->beginStroke("#f0f");
    ();
  };
  piece.loops |> List.iter(pts => drawCurve(pts, g));
  let _ = g->endFill()->endStroke();

  if (drawer.drawsBoundary) {
    let rect' = piece |> Piece.localBoundary;
    let _ =
      g
      ->setStrokeStyle(2.0)
      ->beginStroke("#0f0")
      ->rect(rect'##x, rect'##y, rect'##width, rect'##height);
    ();
  };
  if (drawer.drawsControlLine) {
    let _ = g->setStrokeStyle(2.0)->beginStroke("#fff");
    piece.loops |> List.iter(pts => drawPolyline(pts, g));
  };
  if (drawer.drawsCenter) {
    let pt = piece |> Piece.localBoundary |> Rectangle.center;
    let _ =
      g
      ->setStrokeStyle(2.0)
      ->beginFill("#390")
      ->drawCircle(pt##x, pt##y, drawer.puzzle.linearMeasure /. 32.0);
    ();
  };
};
