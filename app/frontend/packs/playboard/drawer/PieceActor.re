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

let cache = (~scale=1.0, actor: t): unit => {
  let rect = actor.body |> Piece.localBoundary |> Rectangle.inflate(4.0);
  switch (actor.container) {
  | None =>
    actor.shape
  |> DisplayObject.cache(rect##x, rect##y, rect##width, rect##height, scale)
  | Some(c) =>
    c
  |> DisplayObject.cache(rect##x, rect##y, rect##width, rect##height, scale)
  };
};

let unwrapActor = (actor: t): DisplayObject.t =>
  actor.container |> Maybe.fromMaybe(actor.shape);

let withSkin = (f: DisplayObject.t => 'a, actor: t): 'a =>
  actor |> unwrapActor |> f;

let enbox = (target: t, actor: t): unit => {
  open DisplayObject;

  let container =
    switch (actor.container) {
    | None =>
      let s = actor.shape;
      /* actor.shape##uncache(); */
      let container = Container.create();
      s |> copyTransform(container);
      s |> clearTransform;
      s |> parent |> Maybe.traverse_(c => c->Container.addChild(container));
      container->Container.addChild(s);
      /* container##actor #= actor; */
      actor.container = Some(container);
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
  /* actor.cache(); */
  actor.body._localBoundary =
    actor.body._localBoundary
    |> Maybe.map(Rectangle.addRectangle(target.body |> Piece.localBoundary));
  actor.body._boundary = None;
};
