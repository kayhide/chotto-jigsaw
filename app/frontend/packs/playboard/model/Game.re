type t = {
  id: int,
  isStandalone: bool,
  mutable puzzle: Puzzle.t,
  mutable pieces: array(Piece.t),
  mutable image: option(Webapi.Dom.HtmlImageElement.t),
  mutable readyHandlers: EventHandler.handlers(unit),
};

let create = (id: int, canvas): t => {
  let puzzle = Puzzle.create(canvas);
  {
    id,
    isStandalone: 0 == id,
    puzzle,
    pieces: [||],
    image: None,
    readyHandlers: EventHandler.create(),
  };
};

let isReady = (game: t): bool => game.puzzle |> Puzzle.isReady;

let loadContent = (data: string, game: t): unit => {
  game.puzzle->Puzzle.parse(data);
  if (game |> isReady) {
    game.readyHandlers |> EventHandler.fire();
  };
};

let loadImage = (image: Webapi.Dom.HtmlImageElement.t, game: t): unit => {
  game.puzzle |> Puzzle.initizlize(image);
  game.image = Some(image);
  if (game |> isReady) {
    game.readyHandlers |> EventHandler.fire();
  };
};

let onReady = (handler: EventHandler.handler(unit), game: t): unit =>
  game.readyHandlers = game.readyHandlers |> EventHandler.append(handler);
