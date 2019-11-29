type image = Webapi.Dom.HtmlImageElement.t;

type t = {
  id: int,
  isStandalone: bool,
  mutable puzzleActor: PuzzleActor.t,
  mutable pieceActors: array(PieceActor.t),
  image,
  mutable isImageLoaded: bool,
  mutable isUpdated: bool,
  mutable readyHandlers: EventHandler.handlers(unit),
  mutable updatedHandlers: EventHandler.handlers(unit),
};

let create = (id: int, canvas): t => {
  open Webapi.Dom;

  let puzzle = Puzzle.create(canvas);
  let puzzleActor = PuzzleActor.create(puzzle);
  let image = HtmlImageElement.make();
  image->HtmlImageElement.setCrossOrigin(Some("anonymous"));
  {
    id,
    isStandalone: 0 == id,
    isImageLoaded: false,
    isUpdated: false,
    puzzleActor,
    pieceActors: [||],
    image,
    readyHandlers: EventHandler.create(),
    updatedHandlers: EventHandler.create(),
  };
};

let progress = (game: t): float => game.puzzleActor.body |> Puzzle.progress;

let isReady = (game: t): bool =>
  game.puzzleActor.body |> Puzzle.isReady && game.isImageLoaded;

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
  game.puzzleActor.body->Puzzle.parse(data);
  game.pieceActors = game.puzzleActor.body.pieces |> Array.map(PieceActor.create);
  game.pieceActors
  |> Array.map((a: PieceActor.t) => a.shape)
  |> Array.iter(game.puzzleActor.container->Container.addChild);
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

let shuffle = (game: t): unit =>
  {
  open Webapi.Dom;
  open DisplayObject;

  let image' = game.image;
  let width = image'->HtmlImageElement.width;
  let height = image'->HtmlImageElement.height;
  let s = Js.Int.toFloat(Js.Math.max_int(width, height) * 2);
  game.pieceActors
  |> Js.Array.filter((p: PieceActor.t) => p.body |> Piece.isAlive)
  |> Array.iter((p: PieceActor.t) => {
      let center = p.body |> Piece.center;
      let center' = p |> PieceActor.withSkin(a => center |> toGlobalFrom(a));
      let degree = Js.Math.random() *. 360.0 -. 180.0;
      Command.rotate(p.body.id, center', degree)
      |> CommandManager.post(game.puzzleActor.body);
      let vec = Point.create(Js.Math.random() *. s, Js.Math.random() *. s);
      Command.translate(p.body.id, vec |> Point.subtract(center'))
      |> CommandManager.post(game.puzzleActor.body);
    });
  CommandManager.commit();
}

let findPieceActor = (id: int, game: t): PieceActor.t =>
  game.pieceActors[id];

let findPieceEntityActor = (id: int, game: t): PieceActor.t =>
  game.pieceActors[(game.puzzleActor.body |> Puzzle.findPiece(id) |> Piece.entity).id];
