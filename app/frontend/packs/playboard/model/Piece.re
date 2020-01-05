type point = Point.t;
type rectangle = Rectangle.t;

type loop = list(option(point));

type t = {
  id: int,
  mutable loops: list(loop),
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
  let piece = {
    id: src##number,
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

let getLoops = (piece: t): array(loop) =>
  Array.of_list(piece.loops);

let setLoops = (lps: array(loop), piece: t): unit =>
  piece.loops = Array.to_list(lps);

let rec entity = piece: t => piece._merger |> Maybe.maybe(piece, entity);

let merger = piece: option(t) => piece._merger |> Maybe.map(entity);

let setMerger = (merger: t, piece: t): unit => piece._merger = Some(merger);

let isAlive = piece: bool => piece._merger |> Maybe.isNone;

let getNeighborIds = (piece: t): array(int) => piece.neighborIds |> IntSet.elements |> Array.of_list;

let setNeighborIds = (piece: t, ids: array(int)): unit => piece.neighborIds = ids |> Array.to_list |> IntSet.of_list;

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
