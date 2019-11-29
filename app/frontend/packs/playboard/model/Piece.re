type point = Point.t;
type rectangle = Rectangle.t;

type actor =
  | Unboxed(DisplayObject.t)
  | Boxed(DisplayObject.t);

type loop = list(option(point));

type t = {
  id: int,
  mutable loops: list(loop),
  shape: DisplayObject.t,
  mutable actor,
  mutable neighborIds: IntSet.t,
  mutable _position: point,
  mutable _rotation: float,
  mutable _merger: option(t),
  mutable _localBoundary: option(rectangle),
  mutable _boundary: option(rectangle),
};

let parse = src: t => {
  let loop =
    src##points
    |> Array.to_list
    |> List.map(p =>
         p
         |> Js.Nullable.toOption
         |> Maybe.map(p' => Point.create(p'[0], p'[1]))
       );
  let shape = Shape.create();
  let actor = Unboxed(shape);
  let piece = {
    id: src##number,
    shape,
    actor,
    loops: [loop],
    neighborIds: src##neighbors |> Array.to_list |> IntSet.of_list,
    _position: Point.create(0.0, 0.0),
    _rotation: 0.0,
    _merger: None,
    _localBoundary: None,
    _boundary: None,
  };
  piece;
};

let position = (piece: t): point => piece._position;

let setPosition = (pt: point, piece: t): unit => {
  piece._position = pt;
  piece._boundary = None;
};

let rotation = (piece: t): float => piece._rotation;

let setRotation = (deg: float, piece: t): unit => {
  piece._rotation = deg;
  piece._boundary = None;
};

let matrix = piece: Matrix2D.t =>
  Matrix2D.create()
  ->Matrix2D.translate(piece._position##x, piece._position##y)
  ->Matrix2D.rotate(piece._rotation);

let localPoints = piece: list(point) =>
  piece.loops |> List.concat |> Maybe.catMaybes;

let localBoundary = piece: rectangle =>
  switch (piece._localBoundary) {
  | None =>
    let x = Rectangle.fromPoints(piece |> localPoints);
    piece._localBoundary = Some(x);
    x;
  | Some(x) => x
  };

let addLoop = (lp, piece): unit => piece.loops = [lp, ...piece.loops];

let removeLoop = (lp, piece): unit =>
  piece.loops = piece.loops |> List.filter(lp' => lp' !== lp);

let rec entity = piece: t => piece._merger |> Maybe.maybe(piece, entity);

let merger = piece: option(t) => piece._merger |> Maybe.map(entity);

let setMerger = (merger: t, piece: t): unit => piece._merger = Some(merger);

let isAlive = piece: bool => piece._merger |> Maybe.isNone;

let getDegreeTo = (target, piece): float => {
  let deg = target._rotation -. piece._rotation |> mod_float(360.0);
  switch (deg <= (-180.0), 180.0 < deg) {
  | (true, _) => deg +. 360.0
  | (_, true) => deg -. 360.0
  | _ => deg
  };
};

let points = piece: list(point) => {
  let mtx = piece |> matrix;
  piece |> localPoints |> List.map(Point.apply(mtx));
};

let boundary = piece: rectangle =>
  switch (piece._boundary) {
  | None =>
    let mtx = piece |> matrix;
    let rect =
      piece
      |> localBoundary
      |> Rectangle.cornerPoints
      |> List.map(Point.apply(mtx))
      |> Rectangle.fromPoints;
    piece._boundary = Some(rect);
    rect;
  | Some(rect) => rect
  };

let center = piece: point => piece |> boundary |> Rectangle.center;

let cache = (~scale=1.0, piece): unit => {
  let rect = piece |> localBoundary |> Rectangle.inflate(4.0);
  switch (piece.actor) {
  | Unboxed(s) =>
    s
    |> DisplayObject.cache(rect##x, rect##y, rect##width, rect##height, scale)
  | Boxed(s) =>
    s
  |> DisplayObject.cache(rect##x, rect##y, rect##width, rect##height, scale)
  };
};

let unwrapActor = (piece: t): DisplayObject.t =>
  switch (piece.actor) {
  | Unboxed(s) => s
  | Boxed(c) => c
  };

let withActor = (f: DisplayObject.t => 'a, piece: t): 'a =>
  piece |> unwrapActor |> f;

let enbox = (p: t, piece: t): unit => {
  open DisplayObject;
  let container =
    switch (piece.actor) {
    | Unboxed(s) =>
      /* piece.shape##uncache(); */
      let container = Container.create();
      s |> copyTransform(container);
      s |> clearTransform;
      s |> parent |> Maybe.traverse_(c => c->Container.addChild(container));
      container->Container.addChild(s);
      /* container##piece #= piece; */
      piece.actor = Boxed(container);
      container;
    | Boxed(c) => c
    };
  /* p.shape.uncache(); */
  switch (p.actor) {
  | Unboxed(s) =>
    s |> clearTransform;
    container->Container.addChild(s);
  | Boxed(c) =>
    c |> Container.transportTo(container);
    c |> Container.remove;
  };
  /* piece.cache(); */
  piece._localBoundary =
    piece._localBoundary
    |> Maybe.map(Rectangle.addRectangle(p |> localBoundary));
  piece._boundary = None;
};
