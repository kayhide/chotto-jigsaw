open JQuery;

let dragger: ref(Game.dragger) = ref(Game.emptyDragger);
let mover: ref(option(Game.mover)) = ref(None);

let onWheel = (game: Game.t, e): unit => {
  e##preventDefault();
  let e_ = e##originalEvent;
  let pt = Point.create(e_##clientX, e_##clientY);
  dragger := dragger^.continue(pt);

  if (dragger^.active) {
    let delta = - e_##deltaY;
    dragger^.resetSpin(0.0);
    dragger^.spin(delta |> Js.Int.toFloat);
  } else {
    let delta = e_##deltaY < 0 ? 1.02 : 1.0 /. 1.02;
    (game |> Game.getScaler)(pt, delta);
  };
};

let attach = (game: Game.t): unit => {
  Logger.trace("attached: MouseInteractor");
  dragger := game |> Game.defaultDragger;

  let canvas = game.puzzle.stage |> Stage.canvas;
  jquery(canvas)->on("wheel", onWheel(game));

  jquery(canvas)
  ->on("mousedown", e => {
      Logger.trace(e##"type");
      e##preventDefault();
      let pt = Point.create(e##offsetX, e##offsetY);
      dragger := dragger^.continue(pt);
      if (!dragger^.active) {
        mover := game |> Game.getMover(pt) |> Maybe.pure;
      };
    });

  jquery(canvas)
  ->on("mousemove", e => {
      let pt = Point.create(e##offsetX, e##offsetY);
      switch (mover^) {
      | None =>
        if (e##which > 0) {
          dragger^.move(pt);
        }
      | Some(m) => m(pt)
      };
    });

  jquery(canvas)
  ->on("mouseup", e => {
      Logger.trace(e##"type");
      switch (mover^) {
      | None =>
        if (e##which > 0) {
          dragger := dragger^.attempt();
        }
      | Some(_) => mover := None
      };
    });
};
