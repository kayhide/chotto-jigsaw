type piece = Piece.piece;
type puzzle = Puzzle.puzzle;

type t = {
  piece_id: int,
  mergee_id: int,
};

let create = (piece_id: int, mergee_id: int): t => {piece_id, mergee_id};

let execute = (puzzle: puzzle, cmd: t): unit => {
  let piece = puzzle |> Puzzle.findPiece(cmd.piece_id) |> Piece.entity;
  let mergee = puzzle |> Puzzle.findPiece(cmd.mergee_id) |> Piece.entity;

  piece.neighborIds =
    mergee.neighborIds
    |> IntSet.remove(piece.id)
    |> IntSet.union(piece.neighborIds);

  mergee |> Piece.setMerger(piece);

  mergee.loops |> List.iter(lp => piece |> Piece.addLoop(lp));
  piece |> Piece.enbox(mergee);
};

let isValid = (puzzle: puzzle, cmd: t): bool => {
  let mergee = puzzle |> Puzzle.findPiece(cmd.mergee_id);
  mergee |> Piece.isAlive && cmd.piece_id !== cmd.mergee_id;
};
