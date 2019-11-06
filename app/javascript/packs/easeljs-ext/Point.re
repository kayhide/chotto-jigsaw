type display_object =
  {.
   "root": display_object,
  };
type point =
  {.
   [@bs.set] "x": float,
   [@bs.set] "y": float,
   [@bs.set] "on": option(display_object),
  };
type matrix2d;

[@bs.module "@createjs/easeljs"] [@bs.new] external create : (float, float) => point = "Point";

[@bs.send] external clone : (point) => point = "clone";
[@bs.send] external transformPoint : (matrix2d, float, float) => point = "transformPoint";
[@bs.send] external localToLocal : (display_object, float, float, display_object) => point = "localToLocal";
[@bs.send] external windowToLocal : (display_object, float, float) => point = "windowToLocal";
[@bs.send] external localToWindow : (display_object, float, float) => point = "localToWindow";
[@bs.send] external globalToWindow : (display_object, float, float) => point = "globalToWindow";


let isZero = (pt : point) : bool => {
  pt##x == 0.0 && pt##y == 0.0;
};

let add = (pt' : point, pt : point) : point => {
  create(pt##x +. pt'##x, pt##y +. pt'##y);
};

let subtract = (pt' : point, pt : point) : point => {
  create(pt##x -. pt'##x, pt##y -. pt'##y);
};

let scale = (d: float, pt : point) : point => {
  create(pt##x *. d, pt##y *. d);
};

let apply = (mtx : matrix2d, pt : point) : point => {
  mtx->transformPoint(pt##x, pt##y);
};

let distanceTo = (dst : point, src : point) : float => {
  (dst##x -. src##x) ** 2.0 +. (dst##y -. src##y) ** 2.0 |> sqrt;
};

let from_ = (obj : display_object, pt : point) => {
  let pt' = pt->clone;
  pt'##on #= Some(obj);
  pt';
};

let to_ = (obj : display_object, pt : point) => {
  let pt' =
    switch (pt##on) {
    | Some(obj') =>
      if (obj'##root === obj##root) {
        obj'->localToLocal(pt##x, pt##y, obj);
      } else {
        let pt' = obj'->localToWindow(pt##x, pt##y);
        obj->windowToLocal(pt'##x, pt'##y);
      };
    | None =>
      obj->windowToLocal(pt##x, pt##y);
    };
  pt'##on #= Some(obj);
  pt';
};

let fromWindow = (pt : point) : point => {
  let pt' = pt->clone;
  pt'##on #= None;
  pt';
};

let toWindow = (pt : point) : point => {
  let pt' =
    switch (pt##on) {
    | Some(obj') => obj'->globalToWindow(pt##x, pt##y);
    | None => pt->clone;
    };
  pt'##on #= None;
  pt';
};
