open Webapi.Dom;

type puzzle = Puzzle.t;
type rectangle = Rectangle.t;

let contain = (game: Game.t, rect: rectangle): unit => {
  let margin = game.puzzleActor.body.linearMeasure;
  let width = window |> Window.innerWidth |> float_of_int;
  let height = window |> Window.innerHeight |> float_of_int;
  let rect_ = rect |> Rectangle.inflate(margin);
  let sc = Js.Math.min_float(width /. rect_##width, height /. rect_##height);
  game.puzzleActor.container##x
  #= (-. rect_##x *. sc +. (width -. sc *. rect_##width) /. 2.0);
  game.puzzleActor.container##y
  #= (-. rect_##y *. sc +. (height -. sc *. rect_##height) /. 2.0);
  game.puzzleActor.container##scaleX #= sc;
  game.puzzleActor.container##scaleY #= sc;
};

let fit = (game: Game.t): unit =>
  game.puzzleActor.body |> Puzzle.boundary |> contain(game);
