type handler('a) = EventHandler.handler('a);
type handlers('a) = EventHandler.handlers('a);

let current: ref(CommandGroup.t) = ref(CommandGroup.create());
let postHandler: ref(handlers(Command.t)) = ref(EventHandler.create());
let commitHandler: ref(handlers(CommandGroup.t)) =
  ref(EventHandler.create());

let onPost = (handler: handler(Command.t)): unit =>
  postHandler := postHandler^ |> EventHandler.append(handler);

let onCommit = (handler: handler(CommandGroup.t)): unit =>
  commitHandler := commitHandler^ |> EventHandler.append(handler);

let commit = (): unit => {
  let cmds = current^;
  current := CommandGroup.create();
  commitHandler^ |> EventHandler.fire(cmds);
};

let post = (puzzle: Puzzle.t, cmd: Command.t): unit =>
  if (cmd |> Command.isValid(puzzle)) {
    cmd |> Command.execute(puzzle);
    current^ |> CommandGroup.squash(cmd);
    postHandler^ |> EventHandler.fire(cmd);
  };

let receive = (puzzle: Puzzle.t, cmds: CommandGroup.t): unit => {
  cmds.extrinsic = true;
  cmds.commands |> Array.iter(Command.execute(puzzle));
  commitHandler^ |> EventHandler.fire(cmds);
};
