open JQuery;

type point = Point.t;
type piece = PieceActor.t;
type puzzle = PuzzleActor.t;

type t = {
  game: Game.t,
  baseStage: DisplayObject.t,
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

let putToActiveLayer = (p: piece, gi: t): unit => {
  open Webapi.Canvas;
  open DisplayObject;

  gi.activePiece = Some(p);

  let game = gi.game;
  let rect = p.body |> Piece.boundary;
  let pt0 =
    rect |> Rectangle.topLeft |> toWindowFromLocal(game.puzzleActor.container);
  let pt1 =
    rect
    |> Rectangle.bottomRight
    |> toWindowFromLocal(game.puzzleActor.container);

  game.puzzleActor.container |> copyTransform(gi.activeStage);

  let canvas = gi.activeStage |> Stage.canvas;
  canvas->CanvasElement.setWidth(pt1##x -. pt0##x |> int_of_float);
  canvas->CanvasElement.setHeight(pt1##y -. pt0##y |> int_of_float);
  let _ = jquery(canvas)->css("left", pt0##x)->css("top", pt0##y)->show();

  let pt' =
    p.body
    |> Piece.position
    |> toWindowFromLocal(game.puzzleActor.container)
    |> fromWindowToLocal(gi.activeStage);
  p
  |> PieceActor.withSkin(a => {
       a##x #= pt'##x;
       a##y #= pt'##y;
       a##rotation #= (p.body |> Piece.rotation);
       gi.activeStage->Container.addChild(a);
       gi.activeStage->Stage.update;
     });
};

let clearActiveLayer = (gi: t): unit => {
  gi.activePiece
  |> Maybe.traverse_((p: piece) =>
       p
       |> PieceActor.withSkin(a => {
            a##x #= (p.body |> Piece.position)##x;
            a##y #= (p.body |> Piece.position)##y;
            a##rotation #= (p.body |> Piece.rotation);
            gi.game.puzzleActor.container->Container.addChild(a);
          })
     );
  gi.activePiece = None;
  jquery(gi.activeStage->Stage.canvas)->hide();
};

let isCaptured = (piece_id: int, gi: t): bool => {
  gi.game
  |> Game.findPieceActor(piece_id)
  |> PieceActor.withSkin(DisplayObject.parent) === Some(gi.activeStage);
};

let release = (piece_id: int, gi: t): unit => {
  Logger.trace("released[" ++ string_of_int(piece_id) ++ "]");
  CommandManager.commit();
  gi |> clearActiveLayer;
  gi.baseStage |> Stage.invalidate;
};

let handleTranslate = (cmd: TranslateCommand.t, gi: t): unit => {
  let canvas_: Webapi.Dom.Element.t = gi.activeStage |> Stage.canvas;

  let offset = jquery(canvas_)->getOffset();
  jquery(canvas_)
  ->setOffset({
      "left":
        offset##left +. cmd.vector##x *. gi.game.puzzleActor.container##scaleX,
      "top":
        offset##top +. cmd.vector##y *. gi.game.puzzleActor.container##scaleY,
    });
};

let create = (game: Game.t): t => {
  open Webapi.Dom.Document;

  let document = Webapi.Dom.document;
  let baseStage =
    document |> getElementById("field") |> Maybe.fromJust |> Stage.create;
  let activeStage =
    document
    |> getElementById("active-canvas")
    |> Maybe.fromJust
    |> Stage.create;
  let shapeToPiece = Js.Dict.empty();

  game.pieceActors
  |> Array.iter((p: PieceActor.t) =>
       shapeToPiece->Js.Dict.set(p.shape##id |> Js.Int.toString, p)
     );
  baseStage->Container.addChild(game.puzzleActor.container);

  let gi = {game, baseStage, activeStage, shapeToPiece, activePiece: None};

  CommandManager.onPost(cmd => {
    let piece_id = cmd |> Command.pieceId;
    if (gi |> isCaptured(piece_id)) {
      switch (cmd) {
      | Command.Rotate(_) =>
        gi |> putToActiveLayer(game |> Game.findPieceActor(piece_id))
      | Command.Translate(cmd') => gi |> handleTranslate(cmd')
      | _ => ()
      };
    } else {
      let piece = game |> Game.findPieceActor(piece_id);
      piece
      |> PieceActor.withSkin(s => {
           let pt = piece.body |> Piece.position;
           s##x #= pt##x;
           s##y #= pt##y;
           s##rotation #= (piece.body |> Piece.rotation);
         });
      ();
    };
  });

  CommandManager.onCommit(cmds => {
    cmds.commands
    |> Array.iter(cmd =>
         switch (cmd) {
         | Command.Merge(cmd') =>
           let merger = game |> Game.findPieceActor(cmd'.piece_id);
           let mergee = game |> Game.findPieceActor(cmd'.mergee_id);
           merger |> PieceActor.enbox(mergee);
           if (gi |> isCaptured(cmd'.piece_id)) {
             gi |> release(cmd'.piece_id);
           };
           if (gi |> isCaptured(cmd'.mergee_id)) {
             gi |> release(cmd'.mergee_id);
           };
         | Command.Translate(cmd') =>
           let piece = game |> Game.findPieceActor(cmd'.piece_id);
           if (piece.body |> Piece.isAlive) {
             piece
             |> PieceActor.withSkin(s => {
                  s##x #= cmd'.position##x;
                  s##y #= cmd'.position##y;
                  s##rotation #= cmd'.rotation;
                });
           };
         | Command.Rotate(cmd') =>
           let piece = game |> Game.findPieceActor(cmd'.piece_id);
           if (piece.body |> Piece.isAlive) {
             piece
             |> PieceActor.withSkin(s => {
                  s##x #= cmd'.position##x;
                  s##y #= cmd'.position##y;
                  s##rotation #= cmd'.rotation;
                });
           };
         }
       );
    gi.baseStage |> Stage.invalidate;
  });

  Ticker.setFramerate(60);
  Ticker.addEventListener("tick", () =>
    if (baseStage |> Stage.isInvalidated) {
      baseStage |> Stage.update;
      baseStage##invalidated #= false;
    }
  );
  gi;
};

let findPiece = (shape: DisplayObject.t, gi: t): option(piece) =>
  gi.shapeToPiece->Js.Dict.get(shape##id |> Js.Int.toString);

let findPieceEntity = (shape: DisplayObject.t, gi: t): option(piece) =>
  gi
  |> findPiece(shape)
  |> Maybe.map((a: PieceActor.t) =>
       gi.game |> Game.findPieceEntityActor(a.body.id)
     );

let scale = (x: float, y: float, scale: float, gi: t): unit => {
  open DisplayObject;
  let puzzle = gi.game.puzzleActor;
  let pt0 = puzzle.container |> windowToLocal(Point.create(x, y));
  let delta = scale /. (puzzle |> PuzzleActor.currentScale);
  let mtx =
    (puzzle.container |> DisplayObject.matrix)
    ->Matrix2D.translate(pt0##x, pt0##y)
    ->Matrix2D.scale(delta, delta)
    ->Matrix2D.translate(-. pt0##x, -. pt0##y);
  let _ = Js.Obj.assign(puzzle.container, mtx->Matrix2D.decompose());
  gi.baseStage |> Stage.invalidate;
};

let getScaler = (gi: t): scaler => {
  let sc0 = gi.game.puzzleActor |> PuzzleActor.currentScale;
  (pt: point, delta: float) => (
    gi |> scale(pt##x, pt##y, delta *. sc0): unit
  );
};

let getMover = (pt: point, gi: t): mover => {
  let pt0 =
    Point.create(
      pt##x -. gi.game.puzzleActor.container##x,
      pt##y -. gi.game.puzzleActor.container##y,
    );
  pt' => (
    {
      gi.game.puzzleActor.container##x #= (pt'##x -. pt0##x);
      gi.game.puzzleActor.container##y #= (pt'##y -. pt0##y);
      gi.baseStage |> Stage.invalidate;
    }: unit
  );
};

let rec defaultDragger = (gi: t): dragger => {
  active: false,
  piece: None,
  move: _ => (),
  spin: _ => (),
  resetSpin: _ => (),
  attempt: _ => gi |> defaultDragger,
  finish: _ => gi |> defaultDragger,
  continue: (pt: point) => gi |> dragStart(pt),
}
and dragStart = (pt: point, gi: t): dragger =>
  pt
  |> gi.baseStage->DisplayObject.getObjectUnderPoint
  |> Maybe.bind(x => gi |> findPieceEntity(x))
  |> Maybe.maybe(gi |> defaultDragger, (piece: piece) =>
       gi |> capture(piece, pt)
     )
and capture = (piece: piece, pt: point, gi: t): dragger => {
  open DisplayObject;

  Logger.trace("captured[" ++ Js.Int.toString(piece.body.id) ++ "]");
  gi |> putToActiveLayer(piece);
  gi.baseStage |> Stage.invalidate;

  let pt0 = ref(gi.game.puzzleActor.container |> windowToLocal(pt));
  let deg0 = ref(0.0);
  let rec dragger: dragger = {
    active: true,
    piece: Some(piece),
    move: pt' => {
      let pt1 = gi.game.puzzleActor.container |> windowToLocal(pt');
      let vec = pt1 |> Point.subtract(pt0^);
      Command.translate(piece.body.id, vec)
      |> CommandManager.post(gi.game.puzzleActor.body);
      pt0 := pt1;
    },
    spin: (deg: float) => {
      Command.rotate(piece.body.id, pt0^, deg -. deg0^)
      |> CommandManager.post(gi.game.puzzleActor.body);
      deg0 := deg;
    },
    resetSpin: deg => deg0 := deg,
    attempt: () =>
      gi.game.puzzleActor.body
      |> Puzzle.findMergeableOn(piece.body, pt0^)
      |> Maybe.maybe(
           dragger,
           (p': Piece.t) => {
             gi |> release(piece.body.id);
             Command.merge(p'.id, piece.body.id)
             |> CommandManager.post(gi.game.puzzleActor.body);
             CommandManager.commit();
             gi |> defaultDragger;
           },
         ),
    finish: () => {
      gi |> release(piece.body.id);
      gi.game.puzzleActor.body
      |> Puzzle.findMergeableOn(piece.body, pt0^)
      |> Maybe.traverse_((p': Piece.t) => {
           Command.merge(p'.id, piece.body.id)
           |> CommandManager.post(gi.game.puzzleActor.body);
           CommandManager.commit();
         });
      gi |> defaultDragger;
    },
    continue: pt' => {
      let piece' =
        pt'
        |> fromWindowToLocal(gi.activeStage)
        |> gi.activeStage->getObjectUnderPoint
        |> Maybe.bind(x => gi |> findPieceEntity(x))
        |> Maybe.guard(piece' => piece' === piece);

      switch (piece') {
      | None =>
        let _ = dragger.finish();
        gi |> dragStart(pt');
      | Some(_) =>
        pt0 := gi.game.puzzleActor.container |> windowToLocal(pt');
        dragger;
      };
    },
  };
  dragger;
};

let invalidate = (gi: t): unit => gi.baseStage |> Stage.invalidate;

let contain = (rect: Rectangle.t, gi: t): unit => {
  gi.game |> View.contain(rect);
  gi |> invalidate;
};

let fit = (gi: t): unit => {
  gi.game |> View.fit;
  gi |> invalidate;
};
