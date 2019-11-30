type t = {
  body: Puzzle.t,
  shape: DisplayObject.t,
  container: DisplayObject.t,
};

let create = (body: Puzzle.t): t => {
  let shape = Shape.create();
  let container = Container.create();
  container->Container.addChild(shape);

  {
    body,
    shape,
    container,
  };
};

let currentScale = (a: t): float => a.container##scaleX;

let drawWith = (drawer: PuzzleDrawer.t, {body, shape}: t): unit =>
  drawer |> PuzzleDrawer.draw(body, shape##graphics);
