type t;

[@bs.send] external clear: (t, unit) => unit = "clear";
[@bs.send] external setStrokeStyle: (t, float) => t = "setStrokeStyle";
[@bs.send] external beginStroke: (t, string) => t = "beginStroke";
[@bs.send] external endStroke: (t, unit) => t = "endStroke";
[@bs.send] external beginFill: (t, string) => t = "beginFill";
[@bs.send] external beginBitmapFill: (t, 'a) => t = "beginBitmapFill";
[@bs.send] external endFill: (t, unit) => t = "endFill";
[@bs.send] external moveTo: (t, float, float) => t = "moveTo";
[@bs.send] external lineTo: (t, float, float) => t = "lineTo";
[@bs.send]
external bezierCurveTo: (t, float, float, float, float, float, float) => t =
  "bezierCurveTo";
[@bs.send] external rect: (t, float, float, float, float) => t = "rect";
[@bs.send]
external drawRect: (t, float, float, float, float) => t = "drawRect";
[@bs.send] external drawCircle: (t, float, float, float) => t = "drawCircle";
