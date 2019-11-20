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

let isValid = (puzzle: Puzzle.t, cmd: t): bool =>
  switch (cmd) {
  | Merge(cmd') => cmd' |> MergeCommand.isValid(puzzle)
  | Translate(cmd') => cmd' |> TranslateCommand.isValid(puzzle)
  | Rotate(cmd') => cmd' |> RotateCommand.isValid(puzzle)
  };

let execute = (puzzle: Puzzle.t, cmd: t): unit =>
  if (cmd |> isValid(puzzle)) {
    switch (cmd) {
    | Merge(cmd') => cmd' |> MergeCommand.execute(puzzle)
    | Translate(cmd') => cmd' |> TranslateCommand.execute(puzzle)
    | Rotate(cmd') => cmd' |> RotateCommand.execute(puzzle)
    };
  };

/* Helper functions */

let pieceId = (cmd: t): int =>
  switch (cmd) {
  | Merge(cmd') => cmd'.piece_id
  | Translate(cmd') => cmd'.piece_id
  | Rotate(cmd') => cmd'.piece_id
  };

let merge = (piece_id: int, mergee_id: int): t =>
  Merge(MergeCommand.create(piece_id, mergee_id));

let translate = (piece_id: int, vector: Point.t): t =>
  Translate(TranslateCommand.create(piece_id, vector));

let rotate = (piece_id: int, center: Point.t, degree: float): t =>
  Rotate(RotateCommand.create(piece_id, center, degree));

let isMerge = (cmd: t): bool =>
  switch (cmd) {
  | Merge(_) => true
  | _ => false
  };

let isTranslate = (cmd: t): bool =>
  switch (cmd) {
  | Translate(_) => true
  | _ => false
  };

let isRotate = (cmd: t): bool =>
  switch (cmd) {
  | Rotate(_) => true
  | _ => false
  };
