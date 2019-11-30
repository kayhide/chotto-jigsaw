type t = {
  body: Piece.t,
  shape: DisplayObject.t,
  mutable container: option(DisplayObject.t),
};

let create = (body: Piece.t): t => {
  body,
  shape: Shape.create(),
  container: None,
};

let cache = (~scale=1.0, piece: t): unit => {
  let rect = piece.body |> Piece.localBoundary |> Rectangle.inflate(4.0);
  piece.shape
  |> DisplayObject.cache(rect##x, rect##y, rect##width, rect##height, scale);
};

let unwrapActor = (piece: t): DisplayObject.t =>
  piece.container |> Maybe.fromMaybe(piece.shape);

let withSkin = (f: DisplayObject.t => 'a, piece: t): 'a =>
  piece |> unwrapActor |> f;

let enbox = (target: t, piece: t): unit => {
  open DisplayObject;

  let container =
    switch (piece.container) {
    | None =>
      let s = piece.shape;
      /* piece.shape##uncache(); */
      let container = Container.create();
      s |> copyTransform(container);
      s |> clearTransform;
      s |> parent |> Maybe.traverse_(c => c->Container.addChild(container));
      container->Container.addChild(s);
      /* container##piece #= piece; */
      piece.container = Some(container);
      container;
    | Some(c) => c
    };
  /* p.shape.uncache(); */
  switch (target.container) {
  | None =>
    target.shape |> clearTransform;
    container->Container.addChild(target.shape);
  | Some(c) =>
    c |> Container.transportTo(container);
    c |> Container.remove;
  };
  /* piece.cache(); */
  piece.body._localBoundary =
    piece.body._localBoundary
    |> Maybe.map(Rectangle.addRectangle(target.body |> Piece.localBoundary));
  piece.body._boundary = None;
};

let createHitArea = (piece: t): DisplayObject.t => {
  let shape = Shape.create();
  PieceDrawer.drawHitArea(piece.body, shape##graphics);
  shape;
};

let drawWith = (drawer: PieceDrawer.t, piece: t): unit => {
  let {body, shape} = piece;
  drawer |> PieceDrawer.draw(body, shape##graphics);
  piece |> cache;
  shape##hitArea #= (piece |> createHitArea);
};
