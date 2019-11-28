open Webapi.Dom;
open Document;

open JQuery;

type puzzle = Puzzle.t;
type image = Webapi.Dom.HtmlImageElement.t;

module Guider = {
  type t = {
    game: Game.t,
    mutable _active: bool,
  };

  let create = (game: Game.t): t => {
    game,
    _active: false,
  };

  let isActive = (guider: t): bool => guider._active;

  let setActive = (b: bool, guider: t): unit => {
    guider._active = b;
    let _ =
      b ?
        jquery("#active-canvas")->addClass("z-depth-3") :
        jquery("#active-canvas")->removeClass("z-depth-3");

    let drawer = PuzzleDrawer.create(guider.game.image);
    let puzzle = guider.game.puzzle;
    drawer.drawsGuide = b;
    drawer |> PuzzleDrawer.draw(puzzle, puzzle.shape##graphics);
    puzzle.stage |> Stage.invalidate;
  };

  let toggle = (guider: t): unit =>
    guider |> setActive(!(guider |> isActive));
};

let setupLogger = (): unit => {
  Logger.append(Js.log);

  let append' = (log', message: string) => {
    let p = document |> createElement("p");
    p->Element.setTextContent(message);
    log' |> Element.appendChild(p);
  };
  document
  |> getElementById("log")
  |> Maybe.traverse_(log' => Logger.append(append'(log')));
};

let setupUi = (game: Game.t): unit => {

  Ticker.addEventListener("tick", () =>
    jquery("#info .fps")
    ->setText(
        "FPS: "
        ++ (Ticker.getMeasuredFPS() |> Js.Math.round |> Js.Float.toString),
      )
  );

  let _ = jquery("#field")->fadeIn("slow");

  let guider = Guider.create(game);
  let _ =
    jquery(window)
    ->on("keydown", e => {
        if (e##key === "F1") {
          jquery("#log-button")->trigger("click");
        };
        if (e##key === "F2") {
          guider |> Guider.toggle;
        };
      });

  let _ =
    jquery("#log-button")
    ->on("click", _e => {
        let _ = jquery("#log")->fadeToggle();
        let _ = jquery("#log-button")->toggleClass("rotate-180");
        ();
      });

  if (Screen.isFullscreenAvailable()) {
    jquery("[data-action=fullscreen]")
    ->on("click", _ =>
        Screen.toggleFullScreen(jquery("#playboard")->get()[0])
      );
  } else {
    jquery("[data-action=fullscreen]")->addClass("disabled");
  };

  jquery("[data-action=playboard-background]")
  ->on("click", e => {
      let classes: array(string) = e##target##classList |> Js.Array.from;
      classes
      |> Js.Array.find(Js.String.startsWith("bg-"))
      |> Maybe.traverse_(bg => {
           let playground = jquery("#playboard");
           let bgs =
             playground->get()[0]##classList
             |> Js.Array.from
             |> Js.Array.filter(Js.String.startsWith("bg-"));
           bgs |> Js.Array.forEach(x => playground->removeClass(x));
           playground->addClass(bg);
         });
    });

  CommandManager.onCommit(cmds =>
    if (cmds.commands |> Js.Array.some(Command.isMerge)) {
      jquery("#progressbar")
      ->setWidth(
          (
            (game |> Game.progress)
            *. 100.0
            |> Js.Math.floor_int
            |> Js.Int.toString
          )
          ++ "%",
        );
    }
  );
};

[@bs.send] external play: (HtmlElement.t, unit) => unit = "play";
let setupSound = (): unit => {
  let merge: HtmlElement.t = jquery("#sound-list > .merge")->get()[0];

  CommandManager.onPost(cmd =>
    switch (cmd) {
    | Command.Merge(_) => merge->play()
    | _ => ()
    }
  );
};

let connectGameChannel = (game: Game.t): unit => {
  GameChannel.subscribe(game);
  CommandManager.onCommit(GameChannel.commit);
  CommandManager.onCommit(cmds =>
    if (!cmds.extrinsic && cmds.commands |> Js.Array.some(Command.isMerge)) {
      GameChannel.report_progress(game.puzzle |> Puzzle.progress);
    }
  );
};

let play = (): unit => {
  setupLogger();

  let playboard = jquery("#playboard");

  let gameId =
    playboard->data("game-id") |> Js.Nullable.toOption |> Maybe.fromMaybe(0);
  let game =
    document
    |> getElementById("field")
    |> Maybe.fromJust
    |> Game.create(gameId);
  Js.log("game id: " ++ string_of_int(gameId));
  if (game.isStandalone) {
    Js.log("standalone: " ++ string_of_bool(game.isStandalone));
  };

  game
  |> Game.onReady(() => {
       Logger.trace("game ready");

       PuzzleDrawer.create(game.image)
       |> PuzzleDrawer.draw(game.puzzle, game.puzzle.shape##graphics);

       setupUi(game);
       setupSound();

       if (playboard->data("initial-view") !== Js.Nullable.undefined) {
         let size = playboard->data("initial-view");
         Rectangle.create(size##x, size##y, size##width, size##height)
         |> View.contain(game.puzzle);
       };
       let gi = GameInteractor.create(game.puzzle);
       gi |> BrowserInteractor.attach;
       if (Screen.isTouchScreen()) {
         gi |> TouchInteractor.attach;
       } else {
         gi |> MouseInteractor.attach;
       };

       if (game.isStandalone) {
         game |> Game.shuffle;
         let _ = Js.Global.setTimeout(() => game |> Game.setUpdated, 0);
         ();
       };

       jquery("#picture")->fadeOut("slow");
     });

  game
  |> Game.onUpdated(() => {
       Logger.trace("game updated");
       let _ = jquery("#game-progress .loading")->fadeOut("slow");
       game.puzzle |> View.fit;
     });

  if (game.isStandalone) {
    game
    |> Game.loadContent(
         jquery(playboard->data("puzzle-content"))->getText(),
       );
  } else {
    game |> connectGameChannel;
  };

  game |> Game.loadImage(playboard->data("picture"));
};

jquery(document)->ready(play);
