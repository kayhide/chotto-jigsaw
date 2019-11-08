type consumer('props, 'funcs) = {. "subscriptions": subscriptions('props, 'funcs) }
and subscriptions('props, 'funcs)
and sub('props, 'funcs);


[@bs.module "@rails/actioncable"]
  external createConsumer : unit => consumer('props, 'funcs) = "createConsumer";
[@bs.send] external create : (subscriptions('props, 'funcs), 'props, 'funcs) => sub('props, 'funcs) = "create";
[@bs.send] external perform : (sub('props, 'funcs), string, 'a) => unit = "perform";
[@bs.send] external commit : (sub('props, 'funcs), CommandGroup.t) => unit = "commit";


let _received = (puzzle : Puzzle.puzzle, data) : unit => {
  let this = [%raw "this"];
  Logger.trace("received: " ++ data##action);
  switch (data##action) {
  | "init" => {
      this##token #= data##token;
      this->perform("request_update", {});
      ();
    }
  | _ => ();
  };
  if (data##token !== this##token) {
    switch (data##action) {
    | "commit" => {
        let cmds = CommandGroup.create();
        data##commands
        |> Array.map(Bridge.decode)
        |> Array.iter(x => cmds |> CommandGroup.squash(x));
        cmds |> CommandManager.receive(puzzle);
      }
    | _ => ();
    };
  };
};

let _commit = (cmds: CommandGroup.t) : unit => {
  let this = [%raw "this"];
  if (cmds |> CommandGroup.intrinsic) {
    this##perform("commit", {
    "commands": cmds.commands |> Array.map(Bridge.encode)
  });
  }
};

/* let consumer : consumer('props, 'funcs) = createConsumer(); */

let subscribe = (puzzle : Puzzle.puzzle, game_id: int) : sub('props, 'funcs) => {
  let props : 'props = {
    "channel": "GameChannel",
    "game_id": game_id,
  };
  let funcs : 'funcs = {
    "received": _received(puzzle),
    "commit": _commit,
  };
  let consumer : consumer('props, 'funcs) = createConsumer();
  consumer##subscriptions->create(props, funcs);
};
