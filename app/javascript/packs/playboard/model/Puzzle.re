type point = Point.point;
type rectangle = Rectangle.rectangle;
type matrix2d = Matrix2D.matrix2d;
type piece = Piece.piece;
type shape = DisplayObject.t;

type puzzle = {
  stage: shape,
  container: shape,
  shape,
  mutable image: option(Webapi.Dom.HtmlImageElement.t),
  mutable pieces: array(piece),
  mutable linearMeasure: float,
  mutable rotationTolerance: float,
  mutable translationTolerance: float,
};

let create = canvas: puzzle => {
  let stage = Stage.create(canvas);
  let container = Container.create();
  let shape = Shape.create();
  stage->Container.addChild(container);
  container->Container.addChild(shape);

  {
    stage,
    container,
    shape,
    image: None,
    pieces: [||],
    linearMeasure: 0.0,
    rotationTolerance: 24.0,
    translationTolerance: 0.0,
  };
};

[@bs.deriving abstract]
type puzzle_data('a) = {
  pieces: array('a),
  linear_measure: float,
};

[@bs.scope "JSON"] [@bs.val]
external parseData: string => puzzle_data('a) = "parse";

let parse = (puzzle: puzzle, data: string): unit => {
  let content: puzzle_data('a) = parseData(data);
  puzzle.pieces = content |> piecesGet |> Array.map(Piece.parse);
  puzzle.pieces
  |> Array.iter((p: piece) =>
       p |> Piece.unwrapShape |> puzzle.container->Container.addChild
     );
  puzzle.linearMeasure = content |> linear_measureGet;
  puzzle.translationTolerance = puzzle.linearMeasure /. 4.0;
};

let piecesCount = (puzzle: puzzle): int => puzzle.pieces |> Array.length;

let initizlize = (image, puzzle: puzzle): unit => puzzle.image = Some(image);

let progress = puzzle: float => {
  let i =
    puzzle.pieces
    |> Js.Array.filter(p => !(p |> Piece.isAlive))
    |> Array.length;
  Js.Int.toFloat(i) /. Js.Int.toFloat((puzzle.pieces |> Array.length) - 1);
};

let boundary = (puzzle: puzzle): rectangle =>
  puzzle.pieces
  |> Js.Array.filter(Piece.isAlive)
  |> Array.map(p => p |> Piece.boundary)
  |> Array.fold_left(
       (acc, rect) => acc |> Rectangle.addRectangle(rect),
       Rectangle.empty(),
     );
let currentScale = (puzzle: puzzle): float => puzzle.container##scaleX;

[@bs.send] external update: (shape, unit) => unit = "update";
[@bs.send] external invalidate: (shape, unit) => unit = "invalidate";

let invalidate = puzzle: unit => puzzle.stage->invalidate();

let findPiece = (id: int, puzzle: puzzle): piece => puzzle.pieces[id];

let getAdjacentPieces = (piece: piece, puzzle: puzzle): list(piece) =>
  piece.neighborIds
  |> IntSet.elements
  |> List.map(p => puzzle |> findPiece(p) |> Piece.entity);
