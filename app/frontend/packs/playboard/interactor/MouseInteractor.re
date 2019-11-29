open JQuery;

let dragger: ref(GameInteractor.dragger) = ref(GameInteractor.emptyDragger);
let mover: ref(option(GameInteractor.mover)) = ref(None);

let onWheel = (gi: GameInteractor.t, e): unit => {
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
    (gi |> GameInteractor.getScaler)(pt, delta);
  };
};

let attach = (gi: GameInteractor.t): unit => {
  Logger.trace("attached: MouseInteractor");
  dragger := gi |> GameInteractor.defaultDragger;

  let canvas = gi.baseStage |> Stage.canvas;
  jquery(canvas)->on("wheel", onWheel(gi));

  jquery(canvas)
  ->on("mousedown", e => {
      Logger.trace(e##"type");
      e##preventDefault();
      let pt = Point.create(e##offsetX, e##offsetY);
      dragger := dragger^.continue(pt);
      if (!dragger^.active) {
        mover := gi |> GameInteractor.getMover(pt) |> Maybe.pure;
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
