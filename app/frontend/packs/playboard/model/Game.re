type image = Webapi.Dom.HtmlImageElement.t;

type t = {
  id: int,
  isStandalone: bool,
  puzzle: Puzzle.t,
  pieces: array(Piece.t),
  image,
  mutable isImageLoaded: bool,
  mutable isUpdated: bool,
  mutable readyHandlers: EventHandler.handlers(unit),
  mutable updatedHandlers: EventHandler.handlers(unit),
};

let create = (id: int, canvas): t => {
  open Webapi.Dom;

  let puzzle = Puzzle.create(canvas);
  let image = HtmlImageElement.make();
  image->HtmlImageElement.setCrossOrigin(Some("anonymous"));
  {
    id,
    isStandalone: 0 == id,
    isImageLoaded: false,
    isUpdated: false,
    puzzle,
    pieces: [||],
    image,
    readyHandlers: EventHandler.create(),
    updatedHandlers: EventHandler.create(),
  };
};

let progress = (game: t): float => game.puzzle |> Puzzle.progress;

let isReady = (game: t): bool =>
  game.puzzle |> Puzzle.isReady && game.isImageLoaded;

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

let loadImage = (url: string, game: t): unit => {
  open JQuery;
  open Webapi.Dom;

  game.isImageLoaded = true;
  let _ =
    jquery(game.image)
    ->on("load", _e => {
        Logger.trace("image loaded: " ++ Filename.basename(url));
        game |> fireReady;
      });

  url |> game.image->HtmlImageElement.setSrc;
};

let setUpdated = (game: t): unit => {
  game.isUpdated = true;
  game |> fireUpdated;
};

let onReady = (handler: EventHandler.handler(unit), game: t): unit =>
  game.readyHandlers = game.readyHandlers |> EventHandler.append(handler);

let onUpdated = (handler: EventHandler.handler(unit), game: t): unit =>
  game.updatedHandlers = game.updatedHandlers |> EventHandler.append(handler);

let whenReady = (f: unit => unit, game: t): unit =>
  if (game |> isReady) {
    f();
  } else {
    game |> onReady(f);
  };

let shuffle = (game: t): unit => {
  open Webapi.Dom;
  open DisplayObject;

  let image' = game.image;
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
       let vec = Point.create(Js.Math.random() *. s, Js.Math.random() *. s);
       Command.translate(p.id, vec |> Point.subtract(center'))
       |> CommandManager.post(game.puzzle);
     });
  CommandManager.commit();
};
