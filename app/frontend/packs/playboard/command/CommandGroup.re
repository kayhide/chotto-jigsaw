type t = {
  commands: array(Command.t),
  mutable extrinsic: bool,
};

let create = (): t => {commands: [||], extrinsic: false};

let intrinsic = (cg: t): bool => !cg.extrinsic;

let squash = (cmd: Command.t, cg: t): unit => {
  let len = cg.commands |> Js.Array.length;
  if (len === 0) {
    let _ = cg.commands |> Js.Array.push(cmd);
    ();
  } else {
    let last = cg.commands->Array.get(len - 1);
    if (!(last |> Command.squash(cmd))) {
      let _ = cg.commands |> Js.Array.push(cmd);
      ();
    };
  };
};
