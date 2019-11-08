type t = DisplayObject.t;

[@bs.module "@createjs/easeljs"] [@bs.new]
external create: unit => t = "Container";

[@bs.send] external addChild: (t, t) => unit = "addChild";
[@bs.send] external getChildAt: (t, int) => t = "getChildAt";
[@bs.send] external removeChild: (t, t) => unit = "removeChild";

let numChilcren = (obj: t): int =>
  obj##numChildren;

let transportTo = (dst: t, src: t): unit =>
  while (0 < src##numChildren) {
    dst->addChild(src->getChildAt(0));
  };

let projectTo = (dst: t, src: t): unit => {
  let pt0 = src |> DisplayObject.localToWindow(Point.create(0.0, 0.0));
  let pt1 = dst |> DisplayObject.windowToLocal(pt0);
  src##x #= pt1##x;
  src##y #= pt1##y;
  dst->addChild(src);
};

let remove = (obj: t): unit =>
  obj##parent
  |> Js.Nullable.toOption
  |> Maybe.traverse_(x => x->removeChild(obj));
