type point = Point.t;
type rectangle = Rectangle.t;
type matrix2d = Matrix2D.t;
type piece = Piece.t;

type t = {
  mutable pieces: array(piece),
  mutable linearMeasure: float,
  mutable rotationTolerance: float,
  mutable translationTolerance: float,
};

let create = canvas: t => {
  pieces: [||],
  linearMeasure: 0.0,
  rotationTolerance: 24.0,
  translationTolerance: 0.0,
};

[@bs.deriving abstract]
type puzzle_data('a) = {
  pieces: array('a),
  linear_measure: float,
};

[@bs.scope "JSON"] [@bs.val]
external parseData: string => puzzle_data('a) = "parse";

let parse = (puzzle: t, data: string): unit => {
  let content: puzzle_data('a) = parseData(data);
  puzzle.pieces = content |> piecesGet |> Array.map(Piece.parse);
  puzzle.linearMeasure = content |> linear_measureGet;
  puzzle.translationTolerance = puzzle.linearMeasure /. 4.0;
};

let piecesCount = (puzzle: t): int => puzzle.pieces |> Array.length;

let isReady = (puzzle: t): bool => 0 < (puzzle |> piecesCount);

let progress = puzzle: float => {
  let i =
    puzzle.pieces
    |> Js.Array.filter(p => !(p |> Piece.isAlive))
    |> Array.length;
  Js.Int.toFloat(i) /. Js.Int.toFloat((puzzle.pieces |> Array.length) - 1);
};

let boundary = (puzzle: t): rectangle =>
  puzzle.pieces
  |> Js.Array.filter(Piece.isAlive)
  |> Array.map(p => p |> Piece.boundary)
  |> Array.fold_left(
       (acc, rect) => acc |> Rectangle.addRectangle(rect),
       Rectangle.empty(),
     );

let findPiece = (id: int, puzzle: t): piece => puzzle.pieces[id];

let getAdjacentPieces = (piece: piece, puzzle: t): list(piece) =>
  piece.neighborIds
  |> IntSet.elements
  |> List.map(p => puzzle |> findPiece(p) |> Piece.entity)
  |> List.filter((p: piece) => p.id !== piece.id);

let getDegreeTo = (target: piece, source: piece): float => {
  let deg =
    (
      (target |> Piece.rotation)
      -. (source |> Piece.rotation)
      |> Js.Math.floor_int
    )
    mod 360;
  Js.Int.toFloat(deg < (-180) ? deg + 360 : 180 <= deg ? deg - 360 : deg);
};

let isWithinTolerance =
    (source: piece, target: piece, pt: point, puzzle: t): bool =>
  if (Js.Math.abs_float(source |> getDegreeTo(target))
      < puzzle.rotationTolerance) {
    let pt0 = pt |> Point.apply((source |> Piece.matrix)->Matrix2D.invert);
    let pt1 = pt |> Point.apply((target |> Piece.matrix)->Matrix2D.invert);
    pt0 |> Point.distanceTo(pt1) < puzzle.translationTolerance;
  } else {
    false;
  };

let findMergeableOn = (p: piece, point: point, puzzle: t): option(piece) =>
  switch (
    puzzle
    |> getAdjacentPieces(p)
    |> List.find(p1 => puzzle |> isWithinTolerance(p, p1, point))
  ) {
  | p' => Some(p')
  | exception Not_found => None
  };
