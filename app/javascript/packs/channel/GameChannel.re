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
  };

  type subscription = {
    .
    "identifier": identifier,
    /* "consumer": consumer, */
    [@bs.set] "token": token,
  };
};

include ActionCable.Make(X);

[@bs.send] external perform: (subscription, string, 'a) => unit = "perform";
[@bs.send] external commit: (subscription, CommandGroup.t) => unit = "commit";

let subscription: ref(option(subscription)) = ref(None);

let _received = (puzzle: Puzzle.puzzle, data: X.data): unit => {
  let this = subscription^ |> Maybe.fromJust;
  Logger.trace("received: " ++ data##action);
  switch (data##action) {
  | "init" =>
    this##token #= data##token;
    this->perform("request_update", Js.Obj.empty());
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

let _commit = (cmds: CommandGroup.t): unit => {
  let this = subscription^ |> Maybe.fromJust;
  if (cmds |> CommandGroup.intrinsic) {
    this
    ->perform(
        "commit",
        {"commands": cmds.commands |> Array.map(Bridge.encode)},
      );
  };
};

let subscribe = (puzzle: Puzzle.puzzle, game_id: int): subscription => {
  let identifier = {"channel": "GameChannel", "game_id": game_id};
  let funcs = {"received": _received(puzzle), "commit": _commit};
  let consumer = createConsumer();
  let sub = consumer##subscriptions->create(identifier, funcs);
  subscription := Some(sub);
  sub;
};
