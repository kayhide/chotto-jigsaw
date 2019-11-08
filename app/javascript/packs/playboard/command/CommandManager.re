type handler('a) = EventHandler.handler('a);
type handlers('a) = EventHandler.handlers('a);


let history : array(CommandGroup.t) = [||];
let current : ref(CommandGroup.t) = ref(CommandGroup.create());
let postHandler : ref(handlers(Command.t)) = ref(EventHandler.create());
let commitHandler : ref(handlers(CommandGroup.t)) = ref(EventHandler.create());

let onPost = (handler: handler(Command.t)) : unit => {
  postHandler := postHandler^ |> EventHandler.append(handler);
};

let onCommit = (handler: handler(CommandGroup.t)) : unit => {
  commitHandler := commitHandler^ |> EventHandler.append(handler);
};

let commit = () : unit => {
  let cmds = current^;
  let _ = history |> Js.Array.push(cmds);
  current := CommandGroup.create();
  commitHandler^ |> EventHandler.fire(cmds);
};

let post = (puzzle : Puzzle.puzzle, cmd: Command.t) : unit => {
  if (cmd |> Command.isValid(puzzle)) {
    cmd |> Command.execute(puzzle);
    current^ |> CommandGroup.squash(cmd);
    postHandler^ |> EventHandler.fire(cmd);
  }
};

let receive = (puzzle : Puzzle.puzzle, cmds : CommandGroup.t) : unit => {
  cmds.extrinsic = true;
  cmds.commands |> Array.iter(Command.execute(puzzle));
  let _ = history |> Js.Array.push(cmds);
  commitHandler^ |> EventHandler.fire(cmds);
};
