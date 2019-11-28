type t = {
  id: int,
  isStandalone: bool,
  mutable isUpdated: bool,
  mutable puzzle: Puzzle.t,
  mutable pieces: array(Piece.t),
  mutable image: option(Webapi.Dom.HtmlImageElement.t),
  mutable readyHandlers: EventHandler.handlers(unit),
  mutable updatedHandlers: EventHandler.handlers(unit),
};

let create = (id: int, canvas): t => {
  let puzzle = Puzzle.create(canvas);
  {
    id,
    isStandalone: 0 == id,
    isUpdated: false,
    puzzle,
    pieces: [||],
    image: None,
    readyHandlers: EventHandler.create(),
    updatedHandlers: EventHandler.create(),
  };
};

let isReady = (game: t): bool =>
  game.puzzle |> Puzzle.isReady && game.image |> Maybe.isSome;

let fireUpdated = (game: t): unit =>
  if (game |> isReady && game.isUpdated) {
    game.updatedHandlers |> EventHandler.fire();
  };

let fireReady = (game: t): unit =>
  if (game |> isReady) {
    game.readyHandlers |> EventHandler.fire();
    game |> fireUpdated;
  };

let loadContent = (data: string, game: t): unit => {
  game.puzzle->Puzzle.parse(data);
  game |> fireReady;
};

let loadImage = (image: Webapi.Dom.HtmlImageElement.t, game: t): unit => {
  game.image = Some(image);
  game |> fireReady;
};

let setUpdated = (game: t): unit => {
  game.isUpdated = true;
  game |> fireUpdated;
};

let onReady = (handler: EventHandler.handler(unit), game: t): unit =>
  game.readyHandlers = game.readyHandlers |> EventHandler.append(handler);

let onUpdated = (handler: EventHandler.handler(unit), game: t): unit =>
  game.updatedHandlers = game.updatedHandlers |> EventHandler.append(handler);

let shuffle = (game: t): unit =>
  Webapi.Dom.(
    DisplayObject.(
      game.image
      |> Maybe.traverse_(image' => {
           let width = image'->HtmlImageElement.width;
           let height = image'->HtmlImageElement.height;
           let s = Js.Int.toFloat(Js.Math.max_int(width, height) * 2);
           game.puzzle.pieces
           |> Js.Array.filter(Piece.isAlive)
           |> Array.iter(p => {
                let center = p |> Piece.center;
                let center' = center |> toGlobalFrom(p |> Piece.unwrapShape);
                let degree = Js.Math.random() *. 360.0 -. 180.0;
                Command.rotate(p.id, center', degree)
                |> CommandManager.post(game.puzzle);
                let vec =
                  Point.create(Js.Math.random() *. s, Js.Math.random() *. s);
                Command.translate(p.id, vec |> Point.subtract(center'))
                |> CommandManager.post(game.puzzle);
              });
           CommandManager.commit();
         })
    )
  );
let whenReady = (f: unit => unit, game: t): unit =>
  if (game |> isReady) {
    f();
  } else {
    game |> onReady(f);
  };

