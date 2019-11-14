open Js.Json;

let fromList = (xs: list((string, 'a))) => {
  let dict = Js.Dict.empty();
  xs |> List.iter(((k, v)) => dict->Js.Dict.set(k, v));
  dict;
};

let encode = (cmd: Command.t): Js.Json.t =>
  switch (cmd) {
  | Command.Translate(cmd') =>
    [
      ("type", "TranslateCommand" |> string),
      ("piece_id", cmd'.piece_id |> Js.Int.toFloat |> number),
      ("position_x", cmd'.position##x |> number),
      ("position_y", cmd'.position##y |> number),
      ("rotation", cmd'.rotation |> number),
      ("delta_x", cmd'.vector##x |> number),
      ("delta_y", cmd'.vector##y |> number),
    ]
    |> fromList
    |> object_
  | Command.Rotate(cmd') =>
    [
      ("type", "RotateCommand" |> string),
      ("piece_id", cmd'.piece_id |> Js.Int.toFloat |> number),
      ("position_x", cmd'.position##x |> number),
      ("position_y", cmd'.position##y |> number),
      ("rotation", cmd'.rotation |> number),
      ("pivot_x", cmd'.center##x |> number),
      ("pivot_y", cmd'.center##y |> number),
      ("delta_degree", cmd'.degree |> number),
    ]
    |> fromList
    |> object_
  | Command.Merge(cmd') =>
    [
      ("type", "MergeCommand" |> string),
      ("piece_id", cmd'.piece_id |> Js.Int.toFloat |> number),
      ("mergee_id", cmd'.mergee_id |> Js.Int.toFloat |> number),
    ]
    |> fromList
    |> object_
  };

let decode = (src: Js.t('a)): Command.t =>
  switch (src##"type") {
  | "TranslateCommand" =>
    Command.translate(
      src##piece_id,
      Point.create(src##delta_x, src##delta_y),
    )
  | "RotateCommand" =>
    Command.rotate(
      src##piece_id,
      Point.create(src##pivot_x, src##pivot_y),
      src##delta_degree,
    )
  | "MergeCommand" => Command.merge(src##piece_id, src##mergee_id)
  | _ => raise(Invalid_argument("Unknown command type"))
  };
