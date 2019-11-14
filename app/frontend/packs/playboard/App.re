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
    jquery("#fullscreen")
      ->removeClass("hidden")
      ->on("click", () => Screen.toggleFullScreen(jquery("#playboard")->get()[0]));
  };

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

let connectGameChannel = (puzzle: puzzle, game_id: int): unit => {
  let channel = GameChannel.subscribe(puzzle, game_id);
  CommandManager.onCommit(channel->GameChannel.commit);
};

let play = (): unit => {
  setupLogger();

  let playboard = jquery("#playboard");

  let puzzle =
    Puzzle.create(document |> getElementById("field") |> Maybe.fromJust);
  puzzle->Puzzle.parse(jquery(playboard->data("puzzle"))->getText());

  let image = HtmlImageElement.make();
  image->HtmlImageElement.setCrossOrigin(Some("anonymous"));
  let _ =
    jquery(image)
    ->on("load", _e => {
        Logger.trace("image loaded: " ++ (image |> HtmlImageElement.src));
        puzzle |> Puzzle.initizlize(image);
        PuzzleDrawer.create()
        |> PuzzleDrawer.draw(puzzle, puzzle.shape##graphics);

        setupUi(puzzle);
        setupSound();

        let game = Game.create(puzzle);

        if (playboard->data("initial-view") !== Js.Nullable.undefined) {
          let size = playboard->data("initial-view");
          View.contain(
            puzzle,
            Rectangle.create(0.0, 0.0, size##width, size##height),
          );
        };
        if (playboard->data("standalone") !== Js.Nullable.undefined) {
          game |> Game.shuffle;
          /* CommandManager.commit(); */
          puzzle |> View.fit;
        } else {
          connectGameChannel(puzzle, playboard->data("game-id"));
        };

        game |> BrowserInteractor.attach;
        if (Screen.isTouchScreen()) {
          game |> TouchInteractor.attach;
        } else {
          game |> MouseInteractor.attach;
        };
      });

  playboard->data("picture") |> image->HtmlImageElement.setSrc;
};

jquery(document)->ready(play);
