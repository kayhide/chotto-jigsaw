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
  type funcs = {
    .
    "received": data => unit,
    "commit": CommandGroup.t => unit,
    "report_progress": float => unit,
  };

  type subscription = {
    .
    "identifier": identifier,
    /* "consumer": consumer, */
    [@bs.set] "token": token,
  };
};

include ActionCable.Make(X);

[@bs.send] external _perform: (subscription, string, 'a) => unit = "perform";

let subscription: ref(option(subscription)) = ref(None);

let _received = (game: Game.t, data: X.data): unit => {
  let this = subscription^ |> Maybe.fromJust;
  Logger.trace("received: " ++ data##action);
  switch (data##action) {
  | "init" =>
    this##token #= data##token;
    if (!(game |> Game.isReady)) {
      this->_perform("request_content", Js.Obj.empty());
    } else {
      this->_perform("request_update", Js.Obj.empty());
    };
  | "content" =>
    if (!(game |> Game.isReady)) {
      if (data##success) {
        game |> Game.loadContent(data##content);
        this->_perform("request_update", Js.Obj.empty());
      } else {
        Logger.trace("failed: " ++ data##action);
        let _ =
          Js.Global.setTimeout(
            () => this->_perform("request_content", Js.Obj.empty()),
            3000,
          );
        ();
      };
    };
  | "update" =>
    if (!data##success) {
      Logger.trace("failed: " ++ data##action);
      let _ =
        Js.Global.setTimeout(
          () => this->_perform("request_update", Js.Obj.empty()),
          3000,
        );
      ();
    }
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
      cmds |> CommandManager.receive(game.puzzle);
    | _ => ()
    };
  };
};

let commit = (cmds: CommandGroup.t): unit => {
  let this = subscription^ |> Maybe.fromJust;
  if (cmds |> CommandGroup.intrinsic) {
    this
    ->_perform(
        "commit",
        {"commands": cmds.commands |> Array.map(Bridge.encode)},
      );
  };
};

let report_progress = (x: float): unit => {
  let this = subscription^ |> Maybe.fromJust;
  this->_perform("report_progress", {"progress": x});
};

let subscribe = (game: Game.t): unit => {
  let identifier = {"channel": "GameChannel", "game_id": game.id};
  let funcs = {
    "received": _received(game),
    "commit": commit,
    "report_progress": report_progress,
  };
  let consumer = createConsumer();
  let sub = consumer##subscriptions->create(identifier, funcs);
  subscription := Some(sub);
};

let isSubscribing = (): bool => subscription^ |> Maybe.isSome;
