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
    "token": token,
    "commands": any,
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

let _received = (puzzle: Puzzle.t, data: X.data): unit => {
  let this = subscription^ |> Maybe.fromJust;
  Logger.trace("received: " ++ data##action);
  switch (data##action) {
  | "init" =>
    this##token #= data##token;
    this->_perform("request_update", Js.Obj.empty());
    ();
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
      cmds |> CommandManager.receive(puzzle);
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

let subscribe = (puzzle: Puzzle.t, game_id: int): unit => {
  let identifier = {"channel": "GameChannel", "game_id": game_id};
  let funcs = {
    "received": _received(puzzle),
    "commit": commit,
    "report_progress": report_progress,
  };
  let consumer = createConsumer();
  let sub = consumer##subscriptions->create(identifier, funcs);
  subscription := Some(sub);
};

let isSubscribing = (): bool => subscription^ |> Maybe.isSome;
