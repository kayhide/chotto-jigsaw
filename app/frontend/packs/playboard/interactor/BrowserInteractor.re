open JQuery;
open Webapi.Dom;

let onWindowResize = (game: Game.t): unit => {
  let width = window |> Window.innerWidth;
  let height = window |> Window.innerHeight;
  Logger.trace({j|window resized: width: $width, height: $height|j});

  let canvas = game.puzzle.stage |> Stage.canvas;
  canvas->Webapi.Canvas.CanvasElement.setWidth(width);
  canvas->Webapi.Canvas.CanvasElement.setHeight(height);
  let _ =
    jquery(canvas)
    ->css("left", 0)
    ->css("top", 0)
    ->setWidth(width |> Js.Int.toFloat)
    ->setHeight(height |> Js.Int.toFloat);
  game.puzzle.stage |> Stage.invalidate;
};

let attach = (game: Game.t): unit => {
  let _ = jquery(window)->on("resize", _ => onWindowResize(game));
  onWindowResize(game);
};
