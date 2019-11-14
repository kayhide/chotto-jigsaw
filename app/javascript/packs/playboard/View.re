open Webapi.Dom;

type puzzle = Puzzle.t;
type rectangle = Rectangle.t;

let contain = (puzzle: puzzle, rect: rectangle): unit => {
  let margin = puzzle.linearMeasure;
  let width = window |> Window.innerWidth |> float_of_int;
  let height = window |> Window.innerHeight |> float_of_int;
  let rect_ = rect |> Rectangle.inflate(margin);
  let sc = Js.Math.min_float(width /. rect_##width, height /. rect_##height);
  puzzle.container##x
  #= (-. rect_##x *. sc +. (width -. sc *. rect_##width) /. 2.0);
  puzzle.container##y
  #= (-. rect_##y *. sc +. (height -. sc *. rect_##height) /. 2.0);
  puzzle.container##scaleX #= sc;
  puzzle.container##scaleY #= sc;
  puzzle.stage |> Stage.invalidate;
};

let fit = (puzzle: puzzle): unit =>
  puzzle |> Puzzle.boundary |> contain(puzzle);
