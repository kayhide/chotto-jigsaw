type puzzle = Puzzle.t;
type image = Webapi.Dom.HtmlImageElement.t;

type t = {
  image,
  mutable drawsGuide: bool,
};

let create = (image: image): t => {
  image,
  drawsGuide: false,
};

let drawGuide = g: unit => {
  open Graphics;
  let _ =
    g
    ->setStrokeStyle(1.0)
    ->beginStroke("rgba(127,255,255,0.7)")
    ->beginFill("rgba(127,255,255,0.5)")
    ->drawCircle(0.0, 0.0, 5.0);

  let _ = g->setStrokeStyle(1.0)->beginStroke("rgba(127,255,255,0.7)");
  for (i in (-5) to 5) {
    let f = float_of_int(i);
    let _ =
      g
      ->moveTo(-500.0, f *. 100.0)
      ->lineTo(500.0, f *. 100.0)
      ->moveTo(f *. 100.0, -500.0)
      ->lineTo(f *. 100.0, 500.0);
    ();
  };
};

let cacheScale = (puzzle: puzzle): float =>
  Js.Math.min_float(
    Js.Math.max_float(180.0 /. puzzle.linearMeasure, 1.0),
    4.0,
  );

let draw = (puzzle: puzzle, g, drawer: t): unit => {
  open Graphics;
  g->clear();
  if (drawer.drawsGuide) {
    drawGuide(g);
  };

  let drawer' = PieceDrawer.create(drawer.image);

  puzzle.pieces
  |> Array.iter(p => {
       let s = p |> Piece.unwrapShape;
       drawer' |> PieceDrawer.draw(p, s##graphics);
       p |> Piece.cache(~scale=puzzle |> cacheScale);
       let shape = Shape.create();
       PieceDrawer.drawHitArea(p, shape##graphics);
       s##hitArea #= shape;
     });
};
