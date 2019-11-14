type point = Point.t;
type matrix2d = Matrix2D.t;

type t = {
  .
  "id": int,
  [@bs.set] "x": float,
  [@bs.set] "y": float,
  [@bs.set] "scaleX": float,
  [@bs.set] "scaleY": float,
  [@bs.set] "rotation": float,
  [@bs.set] "hitArea": t,
  [@bs.set] "invalidated": bool,
  "parent": Js.nullable(t),
  "graphics": Graphics.t,
  "canvas": Webapi.Dom.Element.t,
  "numChildren": int,
};

[@bs.send] external setTransform: (t, unit) => unit = "setTransform";
[@bs.send]
external _getObjectUnderPoint: (t, float, float) => Js.nullable(t) =
  "getObjectUnderPoint";
[@bs.send]
external _cache: (t, float, float, float, float, float) => unit = "cache";

[@bs.send]
external _localToLocal: (t, float, float, t) => point = "localToLocal";
[@bs.send]
external _localToGlobal: (t, float, float) => point = "localToGlobal";
[@bs.send]
external _globalToLocal: (t, float, float) => point = "globalToLocal";

let position = (obj: t): point => Point.create(obj##x, obj##y);

let matrix = (obj: t): matrix2d =>
  Matrix2D.create()
  ->Matrix2D.appendTransform(
      obj##x,
      obj##y,
      obj##scaleX,
      obj##scaleY,
      obj##rotation,
    );

let parent = (obj: t): option(t) => obj##parent |> Js.Nullable.toOption;

let rec root = (obj: t): t => obj |> parent |> Maybe.maybe(obj, root);

let getCanvas = (obj: t): Webapi.Dom.Element.t => (obj |> root)##canvas;

let getObjectUnderPoint = (obj: t, pt: point): option(t) =>
  obj->_getObjectUnderPoint(pt##x, pt##y) |> Js.Nullable.toOption;

let cache =
    (x: float, y: float, width: float, height: float, scale: float, obj: t)
    : unit =>
  obj->_cache(x, y, width, height, scale);

let copyTransform = (dst: t, src: t): unit => {
  dst##x #= src##x;
  dst##y #= src##y;
  dst##scaleX #= src##scaleX;
  dst##scaleY #= src##scaleY;
  dst##rotation #= src##rotation;
};

let clearTransform = (obj: t): unit => obj->setTransform();

let localToLocal = (pt: point, dst: t, obj: t): point =>
  obj->_localToLocal(pt##x, pt##y, dst);

let localToGlobal = (pt: point, obj: t): point =>
  obj->_localToGlobal(pt##x, pt##y);

let globalToLocal = (pt: point, obj: t): point =>
  obj->_globalToLocal(pt##x, pt##y);

let localToParent = (pt: point, obj: t): point =>
  switch (obj##parent |> Js.Nullable.toOption) {
  | None => obj |> localToGlobal(pt)
  | Some(dst) => obj |> localToLocal(pt, dst)
  };

let localToWindow = (pt: point, obj: t): point => {
  open JQuery;
  let canvas = obj |> getCanvas;
  let pt' = obj |> localToGlobal(pt);
  let offset = jquery(canvas)->getOffset();
  Point.create(pt'##x +. offset##left, pt'##y +. offset##top);
};

let windowToLocal = (pt: point, obj: t): point => {
  open JQuery;
  let canvas = obj |> getCanvas;
  let offset = jquery(canvas)->getOffset();
  let pt' = Point.create(pt##x -. offset##left, pt##y -. offset##top);
  obj |> globalToLocal(pt');
};

let globalToWindow = (pt: point, obj: t): point => {
  let pt = Point.create(pt##x, pt##y);
  obj
  |> getCanvas
  |> (
    elm => {
      open JQuery;
      let offset = jquery(elm)->getOffset();
      Point.create(pt##x +. offset##left, pt##y +. offset##top);
    }
  );
};

let windowToGlobal = (pt: point, obj: t): point => {
  let pt = Point.create(pt##x, pt##y);
  obj
  |> getCanvas
  |> (
    elm => {
      open JQuery;
      let offset = jquery(elm)->getOffset();
      Point.create(pt##x -. offset##left, pt##y -. offset##top);
    }
  );
};

let toGlobalFrom = (obj: t, pt: point): point =>
  obj->_localToGlobal(pt##x, pt##y);

let toWindowFromGlobal = (obj: t, pt: point): point => {
  open JQuery;
  let canvas = obj |> getCanvas;
  let offset = jquery(canvas)->getOffset();
  Point.create(pt##x +. offset##left, pt##y +. offset##top);
};

let toWindowFromLocal = (obj: t, pt: point): point =>
  pt |> toGlobalFrom(obj) |> toWindowFromGlobal(obj);

let fromGlobalTo = (obj: t, pt: point): point =>
  obj->_globalToLocal(pt##x, pt##y);

let fromWindowToGlobal = (obj: t, pt: point): point => {
  open JQuery;
  let canvas = obj |> getCanvas;
  let offset = jquery(canvas)->getOffset();
  let pt' = Point.create(pt##x -. offset##left, pt##y -. offset##top);
  pt';
};

let fromWindowToLocal = (obj: t, pt: point): point =>
  pt |> fromWindowToGlobal(obj) |> fromGlobalTo(obj);
