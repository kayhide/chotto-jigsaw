type point = Point.point;
type piece = Piece.piece;

type t = {
  piece_id: int,
  mutable position: Point.point,
  mutable rotation: float,
  mutable vector: Point.point,
};

let create = (piece_id : int, vector : point) : t => {
  piece_id,
  position: Point.create(0.0, 0.0),
  rotation: 0.0,
  vector,
};

let execute = (puzzle : Puzzle.puzzle, cmd : t) : unit => {
  let piece : piece = puzzle |> Puzzle.findPiece(cmd.piece_id);
  cmd.position = piece |> Piece.position |> Point.add(cmd.vector);
  cmd.rotation = piece |> Piece.rotation;
  piece |> Piece.setPosition(cmd.position);
  piece |> Piece.setRotation(cmd.rotation);
};

let squash = (cmd1 : t, cmd : t) : bool =>
  if (cmd1.piece_id === cmd .piece_id) {
    cmd.vector = cmd.vector |> Point.add(cmd1.vector);
    cmd.position = cmd1.position;
    cmd.rotation = cmd1.rotation;
    true
  } else {
    false
  };

let isValid = (puzzle : Puzzle.puzzle, cmd : t) : bool => {
  let piece = puzzle |> Puzzle.findPiece(cmd.piece_id);
  piece |> Piece.isAlive;
};
