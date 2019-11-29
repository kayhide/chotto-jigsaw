open JQuery;
open Webapi.Dom;

let onWindowResize = (gi: GameInteractor.t): unit => {
  let width = window |> Window.innerWidth;
  let height = window |> Window.innerHeight;
  Logger.trace({j|window resized: width: $width, height: $height|j});

  let canvas = gi.baseStage |> Stage.canvas;
  canvas->Webapi.Canvas.CanvasElement.setWidth(width);
  canvas->Webapi.Canvas.CanvasElement.setHeight(height);
  let _ =
    jquery(canvas)
    ->css("left", 0)
    ->css("top", 0)
    ->setWidth(width |> Js.Int.toFloat)
    ->setHeight(height |> Js.Int.toFloat);
  gi.baseStage |> Stage.invalidate;
};

let attach = (gi: GameInteractor.t): unit => {
  let _ = jquery(window)->on("resize", _ => onWindowResize(gi));
  onWindowResize(gi);
};
