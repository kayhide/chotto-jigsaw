open JQuery;

type point = Point.point;
type piece = Piece.piece;
type puzzle = Puzzle.puzzle;

type t = {
  puzzle,
  activeStage: DisplayObject.t,
  shapeToPiece: Js.Dict.t(piece),
  mutable activePiece: option(piece),
};

type dragger = {
  active: bool,
  piece: option(piece),
  move: point => unit,
  spin: float => unit,
  resetSpin: float => unit,
  attempt: unit => dragger,
  finish: unit => dragger,
  continue: point => dragger,
};

let rec emptyDragger: dragger = {
  active: false,
  piece: None,
  move: _ => (),
  spin: _ => (),
  resetSpin: _ => (),
  attempt: _ => emptyDragger,
  finish: _ => emptyDragger,
  continue: _ => emptyDragger,
};

type scaler = (point, float) => unit;
type mover = point => unit;

let putToActiveLayer = (p: piece, game: t): unit => {
  game.activePiece = Some(p);
  open Webapi.Canvas;
  open DisplayObject;
  let rect = p |> Piece.boundary;
  let pt0 =
    rect |> Rectangle.topLeft |> toWindowFromLocal(game.puzzle.container);
  let pt1 =
    rect |> Rectangle.bottomRight |> toWindowFromLocal(game.puzzle.container);

  game.puzzle.container |> copyTransform(game.activeStage);

  let canvas = game.activeStage |> Stage.canvas;
  canvas->CanvasElement.setWidth(pt1##x -. pt0##x |> int_of_float);
  canvas->CanvasElement.setHeight(pt1##y -. pt0##y |> int_of_float);
  let _ = jquery(canvas)->css("left", pt0##x)->css("top", pt0##y)->show();

  let pt' =
    p
    |> Piece.position
    |> toWindowFromLocal(game.puzzle.container)
    |> fromWindowToLocal(game.activeStage);
  p
  |> Piece.withShape(s => {
       s##x #= pt'##x;
       s##y #= pt'##y;
       s##rotation #= (p |> Piece.rotation);
       game.activeStage->Container.addChild(s);
       game.activeStage->Stage.update;
     });
};

let clearActiveLayer = (game: t): unit => {
  game.activePiece
  |> Maybe.traverse_(p => {
       let s = p |> Piece.unwrapShape;
       s##x #= (p |> Piece.position)##x;
       s##y #= (p |> Piece.position)##y;
       s##rotation #= (p |> Piece.rotation);

       game.puzzle.container->Container.addChild(s);
     });
  game.activePiece = None;
  jquery(game.activeStage->Stage.canvas)->hide();
};

let isCaptured = (piece_id: int, game: t): bool => {
  let p = game.puzzle |> Puzzle.findPiece(piece_id);
  p |> Piece.unwrapShape |> DisplayObject.parent === Some(game.activeStage);
};

let release = (piece_id: int, game: t): unit => {
  Logger.trace("released[" ++ string_of_int(piece_id) ++ "]");
  CommandManager.commit();
  game |> clearActiveLayer;
  game.puzzle.stage |> Stage.invalidate;
};

let handleTranslate = (cmd: TranslateCommand.t, game: t): unit => {
  let canvas_: Webapi.Dom.Element.t = game.activeStage |> Stage.canvas;

  let offset = jquery(canvas_)->getOffset();
  jquery(canvas_)
  ->setOffset({
      "left": offset##left +. cmd.vector##x *. game.puzzle.container##scaleX,
      "top": offset##top +. cmd.vector##y *. game.puzzle.container##scaleY,
    });
};

let create = (puzzle: puzzle): t => {
  let canvas_: Webapi.Dom.Element.t = jquery("#active-canvas")->get()[0];
  let activeStage = Stage.create(canvas_);
  let shapeToPiece = Js.Dict.empty();
  puzzle.pieces
  |> Array.iter(p =>
       shapeToPiece
       ->Js.Dict.set((p |> Piece.unwrapShape)##id |> Js.Int.toString, p)
     );
  let game = {puzzle, activeStage, shapeToPiece, activePiece: None};

  CommandManager.onPost(cmd =>
    switch (cmd) {
    | Command.Rotate(cmd') =>
      let piece = puzzle |> Puzzle.findPiece(cmd'.piece_id);
      game |> putToActiveLayer(piece);
    | Command.Translate(cmd') => game |> handleTranslate(cmd')
    | _ => ()
    }
  );

  CommandManager.onCommit(cmds => {
    cmds.commands
    |> Array.iter(cmd =>
         switch (cmd) {
         | Command.Merge(cmd') =>
           if (game |> isCaptured(cmd'.piece_id)) {
             game |> release(cmd'.piece_id);
           };
           if (game |> isCaptured(cmd'.mergee_id)) {
             game |> release(cmd'.mergee_id);
           };
         | Command.Translate(cmd') =>
           let piece = puzzle |> Puzzle.findPiece(cmd'.piece_id);
           if (piece |> Piece.isAlive) {
             let s = piece |> Piece.unwrapShape;
             s##x #= cmd'.position##x;
             s##y #= cmd'.position##y;
             s##rotation #= cmd'.rotation;
           };
         | Command.Rotate(cmd') =>
           let piece = puzzle |> Puzzle.findPiece(cmd'.piece_id);
           if (piece |> Piece.isAlive) {
             let s = piece |> Piece.unwrapShape;
             s##x #= cmd'.position##x;
             s##y #= cmd'.position##y;
             s##rotation #= cmd'.rotation;
           };
         }
       );
    game.puzzle.stage |> Stage.invalidate;
  });

  Ticker.setFramerate(60);
  Ticker.addEventListener("tick", () =>
    if (puzzle.stage |> Stage.isInvalidated) {
      puzzle.stage |> Stage.update;
      puzzle.stage##invalidated #= false;
    }
  );
  game;
};

let findPiece = (shape: DisplayObject.t, game: t): option(piece) =>
  game.shapeToPiece->Js.Dict.get(shape##id |> Js.Int.toString);

let scale = (x: float, y: float, scale: float, game: t): unit => {
  open DisplayObject;
  let puzzle = game.puzzle;
  let pt0 = puzzle.container |> windowToLocal(Point.create(x, y));
  let delta = scale /. (puzzle |> Puzzle.currentScale);
  let mtx =
    (puzzle.container |> DisplayObject.matrix)
    ->Matrix2D.translate(pt0##x, pt0##y)
    ->Matrix2D.scale(delta, delta)
    ->Matrix2D.translate(-. pt0##x, -. pt0##y);
  let _ = Js.Obj.assign(puzzle.container, mtx->Matrix2D.decompose());
  puzzle.stage |> Stage.invalidate;
};

let getScaler = (game: t): scaler => {
  let sc0 = game.puzzle |> Puzzle.currentScale;
  (pt: point, delta: float) => (
    game |> scale(pt##x, pt##y, delta *. sc0): unit
  );
};

let getMover = (pt: point, game: t): mover => {
  let pt0 =
    Point.create(
      pt##x -. game.puzzle.container##x,
      pt##y -. game.puzzle.container##y,
    );
  pt' => (
    {
      game.puzzle.container##x #= (pt'##x -. pt0##x);
      game.puzzle.container##y #= (pt'##y -. pt0##y);
      game.puzzle.stage |> Stage.invalidate;
    }: unit
  );
};

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
    (source: piece, target: piece, pt: point, game: t): bool =>
  if (Js.Math.abs_float(source |> getDegreeTo(target))
      < game.puzzle.rotationTolerance) {
    let pt0 = pt |> Point.apply((source |> Piece.matrix)->Matrix2D.invert);
    let pt1 = pt |> Point.apply((target |> Piece.matrix)->Matrix2D.invert);
    pt0 |> Point.distanceTo(pt1) < game.puzzle.translationTolerance;
  } else {
    false;
  };

let findMergeableOn = (p: piece, point: point, game: t): option(piece) =>
  switch (
    game.puzzle
    |> Puzzle.getAdjacentPieces(p)
    |> List.find(p1 => game |> isWithinTolerance(p, p1, point))
  ) {
  | p' => Some(p')
  | exception Not_found => None
  };

let rec defaultDragger = (game: t): dragger => {
  active: false,
  piece: None,
  move: _ => (),
  spin: _ => (),
  resetSpin: _ => (),
  attempt: _ => game |> defaultDragger,
  finish: _ => game |> defaultDragger,
  continue: (pt: point) => game |> dragStart(pt),
}
and dragStart = (pt: point, game: t): dragger =>
  DisplayObject.(
    pt
    |> game.puzzle.stage->getObjectUnderPoint
    |> Maybe.bind(x => game |> findPiece(x))
    |> Maybe.map(Piece.entity)
    |> Maybe.maybe(game |> defaultDragger, (piece: piece) =>
         game |> capture(piece, pt)
       )
  )
and capture = (piece: piece, pt: point, game: t): dragger => {
  open DisplayObject;

  Logger.trace("captured[" ++ Js.Int.toString(piece.id) ++ "]");
  game |> putToActiveLayer(piece);
  game.puzzle.stage |> Stage.invalidate;

  let pt0 = ref(game.puzzle.container |> windowToLocal(pt));
  let deg0 = ref(0.0);
  let rec dragger: dragger = {
    active: true,
    piece: Some(piece),
    move: pt' => {
      let pt1 = game.puzzle.container |> windowToLocal(pt');
      let vec = pt1 |> Point.subtract(pt0^);
      Command.translate(piece.id, vec) |> CommandManager.post(game.puzzle);
      pt0 := pt1;
    },
    spin: (deg: float) => {
      Command.rotate(piece.id, pt0^, deg -. deg0^)
      |> CommandManager.post(game.puzzle);
      deg0 := deg;
    },
    resetSpin: deg => deg0 := deg,
    attempt: () =>
      game
      |> findMergeableOn(piece, pt0^)
      |> Maybe.maybe(
           dragger,
           (p': piece) => {
             game |> release(piece.id);
             Command.merge(p'.id, piece.id)
             |> CommandManager.post(game.puzzle);
             CommandManager.commit();
             game |> defaultDragger;
           },
         ),
    finish: () => {
      game |> release(piece.id);
      game
      |> findMergeableOn(piece, pt0^)
      |> Maybe.traverse_((p': piece) => {
           Command.merge(p'.id, piece.id) |> CommandManager.post(game.puzzle);
           CommandManager.commit();
         });
      game |> defaultDragger;
    },
    continue: pt' => {
      let piece' =
        pt'
        |> fromWindowToLocal(game.activeStage)
        |> game.activeStage->getObjectUnderPoint
        |> Maybe.bind(x => game |> findPiece(x))
        |> Maybe.guard(piece' => piece' === piece);

      switch (piece') {
      | None =>
        let _ = dragger.finish();
        game |> dragStart(pt');
      | Some(_) =>
        pt0 := game.puzzle.container |> windowToLocal(pt');
        dragger;
      };
    },
  };
  dragger;
};

let shuffle = ({puzzle}: t): unit =>
  Webapi.Dom.(
    DisplayObject.(
      puzzle.image
      |> Maybe.traverse_(image' => {
           let width = image'->HtmlImageElement.width;
           let height = image'->HtmlImageElement.height;
           let s = Js.Int.toFloat(Js.Math.max_int(width, height) * 2);
           puzzle.pieces
           |> Js.Array.filter(Piece.isAlive)
           |> Array.iter(p => {
                let center = p |> Piece.center;
                let center' = p |> Piece.unwrapShape |> localToParent(center);
                Command.rotate(
                  p.id,
                  center',
                  Js.Math.random() *. 360.0 -. 180.0,
                )
                |> CommandManager.post(puzzle);
                let vec =
                  Point.create(Js.Math.random() *. s, Js.Math.random() *. s);
                Command.translate(p.id, vec |> Point.subtract(center'))
                |> CommandManager.post(puzzle);
              });
         })
    )
  );
