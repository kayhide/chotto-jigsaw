open Webapi.Dom;
open JQuery;

external fromTokenList: DomTokenList.t => Js.Array.array_like(DomTokenList.t) =
  "%identity";

[@bs.send] external play: (Element.t, unit) => unit = "play";

type app = {
  playboard: Webapi.Dom.Element.t,
  field: Webapi.Dom.Element.t,
  sounds: Webapi.Dom.Element.t,
  log: option(Webapi.Dom.Element.t),
};

let setupLogger = (): unit => {
  open Document;

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

let setupUi = (game: Game.t, app: app): unit => {
  open Document;

  Ticker.addEventListener("tick", () =>
    jquery("#info .fps")
    ->setText(
        "FPS: "
        ++ (Ticker.getMeasuredFPS() |> Js.Math.round |> Js.Float.toString),
      )
  );

  let _ = jquery("#field")->fadeIn("slow");

  let _ =
    jquery("#log-button")
    ->on("click", _e => {
        let _ = jquery("#log")->fadeToggle();
        let _ = jquery("#log-button")->toggleClass("rotate-180");
        ();
      });

  if (Screen.isFullscreenAvailable()) {
    jquery("[data-action=fullscreen]")
    ->on("click", _ => Screen.toggleFullScreen(app.playboard));
  } else {
    jquery("[data-action=fullscreen]")->addClass("disabled");
  };

  jquery("[data-action=playboard-background]")
  ->on("click", e => {
      let classes: array(string) = e##target##classList |> Js.Array.from;
      classes
      |> Js.Array.find(Js.String.startsWith("bg-"))
      |> Maybe.traverse_(bg => {
           let elm =
             document |> getElementById("playboard") |> Maybe.fromJust;
           let playground = jquery("#playboard");
           let bgs =
             elm
             |> Element.classList
             |> fromTokenList
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

let setupSound = (app: app): unit =>
  app.sounds
  |> Element.querySelector(".merge")
  |> Maybe.traverse_(elm =>
       CommandManager.onPost(cmd =>
         switch (cmd) {
         | Command.Merge(_) => elm->play()
         | _ => ()
         }
       )
     );

let connectGameChannel = (game: Game.t): unit => {
  let sub = GameChannel.subscribe(game);
  CommandManager.onCommit(sub->GameChannel.commit);
  CommandManager.onCommit(cmds =>
    if (!cmds.extrinsic && cmds.commands |> Js.Array.some(Command.isMerge)) {
      sub->GameChannel.report_progress(game |> Game.progress);
    }
  );
};

let play = (app: app): unit => {
  setupLogger();

  let gameId =
    jquery(app.playboard)->data("game-id")
    |> Js.Nullable.toOption
    |> Maybe.fromMaybe(0);
  let game = Game.create(gameId, app.field);
  Js.log("game id: " ++ string_of_int(gameId));
  if (game.isStandalone) {
    Js.log("standalone: " ++ string_of_bool(game.isStandalone));
  };

  game
  |> Game.onReady(() => {
       Logger.trace("game ready");

       PuzzleDrawer.(
         create(game.image)
         |> draw(game.puzzleActor.body, game.puzzleActor.shape##graphics)
       );

       PieceDrawer.(
         create(game.image)
         |> (
           d =>
             game.pieceActors
             |> Array.iter((p: PieceActor.t) =>
                  draw(p.body, p.shape##graphics, d)
                )
         )
       );

       app |> setupUi(game);
       app |> setupSound;

       if (jquery(app.playboard)->data("initial-view")
           !== Js.Nullable.undefined) {
         let size = jquery(app.playboard)->data("initial-view");
         Rectangle.create(size##x, size##y, size##width, size##height)
         |> View.contain(game);
       };

       let gi = GameInteractor.create(game);
       gi |> BrowserInteractor.attach;
       gi |> GuideInteractor.attach;
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
       game |> View.fit;
     });

  if (game.isStandalone) {
    game
    |> Game.loadContent(
         jquery(jquery(app.playboard)->data("puzzle-content"))->getText(),
       );
  } else {
    game |> connectGameChannel;
  };

  game |> Game.loadImage(jquery(app.playboard)->data("picture"));
};

jquery(document)
->ready(() => {
    open Document;
    let playboard = document |> getElementById("playboard") |> Maybe.fromJust;
    let field = document |> getElementById("field") |> Maybe.fromJust;
    let sounds = document |> getElementById("sounds") |> Maybe.fromJust;
    let log = document |> getElementById("log");
    let app: app = {playboard, field, sounds, log};
    app |> play;
  });
