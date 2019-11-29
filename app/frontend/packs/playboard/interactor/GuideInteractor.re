type t = {
  gi: GameInteractor.t,
  mutable isActive: bool,
};

let setActive = (b: bool, guide: t): unit => {
  open JQuery;

  guide.isActive = b;
  let _ =
    b ?
      jquery("#active-canvas")->addClass("z-depth-3") :
      jquery("#active-canvas")->removeClass("z-depth-3");

  let game = guide.gi.game;
  let drawer = PuzzleDrawer.create(game.image);
  drawer.drawsGuide = b;
  drawer
  |> PuzzleDrawer.draw(
       game.puzzleActor.body,
       game.puzzleActor.shape##graphics,
     );
  guide.gi.baseStage |> Stage.invalidate;
};

let toggle = (guide: t): unit => guide |> setActive(!guide.isActive);

let attach = (gi: GameInteractor.t): unit => {
  open JQuery;
  let guide = {gi, isActive: false};
  let _ =
    jquery(Webapi.Dom.window)
    ->on("keydown", e => {
        if (e##key === "F1") {
          jquery("#log-button")->trigger("click");
        };
        if (e##key === "F2") {
          guide |> toggle;
        };
      });
  ();
};
