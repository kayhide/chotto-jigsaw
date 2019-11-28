open Webapi.Dom;
open Document;

open JQuery;

type puzzle = Puzzle.t;

module Guider = {
  type t = {
    puzzle,
    drawer: PuzzleDrawer.t,
    mutable _active: bool,
  };

  let create = (puzzle: puzzle): t => {
    puzzle,
    drawer: PuzzleDrawer.create(),
    _active: false,
  };

  let isActive = (guider: t): bool => guider._active;

  let setActive = (b: bool, guider: t): unit => {
    guider._active = b;
    let _ =
      b ?
        jquery("#active-canvas")->addClass("z-depth-3") :
        jquery("#active-canvas")->removeClass("z-depth-3");

    guider.drawer.drawsGuide = b;
    guider.drawer
    |> PuzzleDrawer.draw(guider.puzzle, guider.puzzle.shape##graphics);
    guider.puzzle.stage |> Stage.invalidate;
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

let setupUi = (puzzle: puzzle): unit => {
  Ticker.addEventListener("tick", () =>
    jquery("#info .fps")
    ->setText(
        "FPS: "
        ++ (Ticker.getMeasuredFPS() |> Js.Math.round |> Js.Float.toString),
      )
  );

  let _ = jquery("#field")->fadeIn("slow");

  let guider = Guider.create(puzzle);
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
            (puzzle |> Puzzle.progress)
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
  Js.log("standalone: " ++ string_of_bool(game.isStandalone));

  game
  |> Game.onReady(() => {
       Logger.trace("game ready");

       PuzzleDrawer.create()
       |> PuzzleDrawer.draw(game.puzzle, game.puzzle.shape##graphics);

       setupUi(game.puzzle);
       setupSound();

       let gi = GameInteractor.create(game.puzzle);

       if (playboard->data("initial-view") !== Js.Nullable.undefined) {
         let size = playboard->data("initial-view");
         Rectangle.create(size##x, size##y, size##width, size##height)
         |> View.contain(game.puzzle);
       };
       if (game.isStandalone) {
         gi |> GameInteractor.shuffle;
         /* CommandManager.commit(); */
         game.puzzle |> View.fit;
       };

       gi |> BrowserInteractor.attach;
       if (Screen.isTouchScreen()) {
         gi |> TouchInteractor.attach;
       } else {
         gi |> MouseInteractor.attach;
       };

       jquery("#picture")->fadeOut("slow");
     });

  if (game.isStandalone) {
    game.puzzle
    ->Puzzle.parse(jquery(playboard->data("puzzle-content"))->getText());
  } else {
    game |> connectGameChannel;
  };

  let image = HtmlImageElement.make();
  image->HtmlImageElement.setCrossOrigin(Some("anonymous"));
  let _ =
    jquery(image)
    ->on("load", _e => {
        Logger.trace(
          "image loaded: "
          ++ (image |> HtmlImageElement.src |> Filename.basename),
        );
        game |> Game.loadImage(image);
      });

  playboard->data("picture") |> image->HtmlImageElement.setSrc;
};

jquery(document)->ready(play);
