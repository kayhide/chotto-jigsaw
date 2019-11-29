type any;
external fromAny: any => 'a = "%identity";

module X = {
  type identifier = {
    .
    "channel": string,
    "game_id": int,
  };

  type token = string;
  type data = {
    .
    "action": string,
    "success": bool,
    "token": token,
    "commands": any,
    "content": string,
  };

  type subscription = {
    .
    "identifier": identifier,
    /* "consumer": consumer, */
    [@bs.set] "token": token,
    [@bs.set] "game": Game.t,
  };

  type funcs = {. "received": [@bs.this] ((subscription, data) => unit)};
};

include ActionCable.Make(X);

let retryOnFailAndThen =
    (action: string, data: X.data, f: unit => unit, this: subscription): unit =>
  if (data##action == action) {
    if (data##success) {
      f();
    } else {
      Logger.trace("failed: " ++ data##action);
      let _ =
        Js.Global.setTimeout(
          () => this->perform("request_" ++ action, Js.Obj.empty()),
          3000,
        );
      ();
    };
  };

let _received =
  [@bs.this]
  (
    (this: subscription, data: X.data) => (
      {
        Logger.trace("received: " ++ data##action);

        let game = this##game;
        this
        |> retryOnFailAndThen(
             "content",
             data,
             () => {
               game |> Game.loadContent(data##content);
               this->perform("request_update", Js.Obj.empty());
             },
           );
        this
        |> retryOnFailAndThen("update", data, () => game |> Game.setUpdated);

        switch (data##action) {
        | "init" =>
          this##token #= data##token;
          if (!(game |> Game.isReady)) {
            this->perform("request_content", Js.Obj.empty());
          };
        | _ => ()
        };
        if (data##token !== this##token) {
          switch (data##action) {
          | "commit" =>
            let cmds = CommandGroup.create();
            data##commands
            |> fromAny
            |> Array.map(Bridge.decode)
            |> Array.iter(x => cmds |> CommandGroup.squash(x));
            game
            |> Game.whenReady(() =>
                 cmds |> CommandManager.receive(game.puzzle)
               );
          | _ => ()
          };
        };
      }: unit
    )
  );

let commit = (this: subscription, cmds: CommandGroup.t): unit =>
  if (cmds |> CommandGroup.intrinsic) {
    this
    ->perform(
        "commit",
        {"commands": cmds.commands |> Array.map(Bridge.encode)},
      );
  };

let report_progress = (this: subscription, x: float): unit =>
  this->perform("report_progress", {"progress": x});

let subscribe = (game: Game.t): subscription => {
  let identifier = {"channel": "GameChannel", "game_id": game.id};
  let funcs = {"received": _received};
  let consumer = createConsumer();
  let sub = consumer##subscriptions->create(identifier, funcs);
  sub##game #= game;
  sub;
};
