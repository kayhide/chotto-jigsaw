type merge = MergeCommand.t;
type translate = TranslateCommand.t;
type rotate = RotateCommand.t;

type t =
  | Merge(merge)
  | Translate(translate)
  | Rotate(rotate);

let squash = (cmd1: t, cmd: t): bool =>
  switch (cmd1, cmd) {
  | (Translate(cmd1'), Translate(cmd')) =>
    TranslateCommand.squash(cmd1', cmd')
  | (Rotate(cmd1'), Rotate(cmd')) => RotateCommand.squash(cmd1', cmd')
  | _ => false
  };

let execute = (puzzle: Puzzle.puzzle, cmd: t): unit =>
  switch (cmd) {
  | Merge(cmd') => cmd' |> MergeCommand.execute(puzzle)
  | Translate(cmd') => cmd' |> TranslateCommand.execute(puzzle)
  | Rotate(cmd') => cmd' |> RotateCommand.execute(puzzle)
  };

let isValid = (puzzle: Puzzle.puzzle, cmd: t): bool =>
  switch (cmd) {
  | Merge(cmd') => cmd' |> MergeCommand.isValid(puzzle)
  | Translate(cmd') => cmd' |> TranslateCommand.isValid(puzzle)
  | Rotate(cmd') => cmd' |> RotateCommand.isValid(puzzle)
  };

let merge = (piece_id: int, mergee_id: int): t =>
  Merge(MergeCommand.create(piece_id, mergee_id));

let translate = (piece_id: int, vector: Point.point): t =>
  Translate(TranslateCommand.create(piece_id, vector));

let rotate = (piece_id: int, center: Point.point, degree: float): t =>
  Rotate(RotateCommand.create(piece_id, center, degree));
