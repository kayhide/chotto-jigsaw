type point = Point.t;
type piece = Piece.t;

type t = {
  piece_id: int,
  mutable position: point,
  mutable rotation: float,
  center: point,
  mutable degree: float,
};

let create = (piece_id: int, center: point, degree: float): t => {
  piece_id,
  position: Point.create(0.0, 0.0),
  rotation: 0.0,
  center,
  degree,
};

let execute = (puzzle: Puzzle.t, cmd: t): unit => {
  let mtx =
    Matrix2D.create()
    ->Matrix2D.translate(cmd.center##x, cmd.center##y)
    ->Matrix2D.rotate(cmd.degree)
    ->Matrix2D.translate(-. cmd.center##x, -. cmd.center##y);

  let piece: piece = puzzle |> Puzzle.findPiece(cmd.piece_id);
  cmd.position = piece |> Piece.position |> Point.apply(mtx);
  cmd.rotation = (piece |> Piece.rotation) +. cmd.degree;
  piece |> Piece.setPosition(cmd.position);
  piece |> Piece.setRotation(cmd.rotation);
};

let squash = (cmd1: t, cmd: t): bool =>
  if (cmd1.piece_id === cmd.piece_id
      &&
      cmd1.center##x ===
      cmd.center##x
      &&
      cmd1.center##y ===
      cmd.center##y) {
    cmd.degree = cmd.degree +. cmd1.degree;
    cmd.position = cmd1.position;
    cmd.rotation = cmd1.rotation;
    true;
  } else {
    false;
  };

let isValid = (puzzle: Puzzle.t, cmd: t): bool =>
  puzzle |> Puzzle.findPiece(cmd.piece_id) |> Piece.isAlive;
