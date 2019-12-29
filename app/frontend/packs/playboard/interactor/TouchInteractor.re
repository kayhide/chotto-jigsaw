let dragger: ref(GameInteractor.dragger) = ref(GameInteractor.emptyDragger);
let mover: ref(option(GameInteractor.mover)) = ref(None);
let scaler: ref(option(GameInteractor.scaler)) = ref(None);
let pressed: ref(bool) = ref(false);

let setupHammer = (canvas: Webapi.Dom.Element.t): Hammer.t => {
  open Hammer;
  let hammer = Hammer.create(canvas);

  hammer
  ->get("pan")
  ->set({"enable": true, "pointers": 1, "direction": Hammer.direction_all});
  hammer->get("pinch")->set({"enable": true, "threshold": 0.1});
  hammer->get("pinch")->recognizeWith(hammer->get("pan"));
  hammer->get("tap")->set({"enable": true, "pointers": 1});
  hammer->get("press")->set({"enable": true, "pointers": 1});
  hammer->get("doubletap")->set({"enable": true, "pointers": 2});
  hammer->get("rotate")->set({"enable": false, "pointers": 2});
  hammer;
};

let updateListeners = (hammer: Hammer.t): unit =>
  Hammer.(
    if (dragger^.active) {
      hammer->get("pinch")->set({"enable": false});
      hammer->get("rotate")->set({"enable": true});
    } else {
      hammer->get("pinch")->set({"enable": true});
      hammer->get("rotate")->set({"enable": false});
    }
  );

let attach = (gi: GameInteractor.t): unit => {
  Logger.trace("attached: TouchInteractor");
  dragger := gi |> GameInteractor.defaultDragger;
  open Hammer;
  let hammer = setupHammer(gi.baseStage |> Stage.canvas);

  hammer
  ->on("tap", e => {
      Logger.trace(e##"type");
      dragger := dragger^.continue(e##center);
      dragger := dragger^.attempt();
      pressed := true;
      hammer |> updateListeners;
    });

  hammer
  ->on("doubletap", e => {
      Logger.trace(e##"type");
      dragger := dragger^.finish();
      hammer |> updateListeners;
      gi |> GameInteractor.fit;
    });

  hammer
  ->on("press", e => {
      Logger.trace(e##"type");
      dragger := dragger^.finish();
      mover := gi |> GameInteractor.getMover(e##center) |> Maybe.pure;
      pressed := true;
      hammer |> updateListeners;
    });

  hammer
  ->on("pinchstart", e => {
      Logger.trace(e##"type");
      dragger := dragger^.finish();
      scaler := gi |> GameInteractor.getScaler |> Maybe.pure;
      hammer |> updateListeners;
    });

  hammer
  ->on("pinchmove", e =>
      scaler^ |> Maybe.traverse_(f => f(e##center, e##scale))
    );

  hammer
  ->on("panstart", e => {
      Logger.trace(e##"type");
      if (! pressed^) {
        dragger := dragger^.continue(e##center);
      };
      if (dragger^.active) {
        mover := None;
      } else {
        dragger := dragger^.attempt();
        mover := gi |> GameInteractor.getMover(e##center) |> Maybe.pure;
      };
      hammer |> updateListeners;
    });
  hammer
  ->on("panmove", e => {
      dragger^.move(e##center);
      mover^ |> Maybe.traverse_(f => f(e##center));
    });
  hammer
  ->on("panend", _ => {
      dragger := dragger^.attempt();
      pressed := false;
      hammer |> updateListeners;
    });

  hammer
  ->on("rotatestart", e => {
      Logger.trace(e##"type");
      hammer->get("drag")->set({"enable": false});
    });
  hammer->on("rotatemove", e => dragger^.spin(e##rotation *. 3.0));
};
