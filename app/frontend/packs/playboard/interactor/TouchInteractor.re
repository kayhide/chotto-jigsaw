let dragger: ref(GameInteractor.dragger) = ref(GameInteractor.emptyDragger);
let mover: ref(option(GameInteractor.mover)) = ref(None);
let scaler: ref(option(GameInteractor.scaler)) = ref(None);

let setupHammer = (canvas: Webapi.Dom.Element.t): Hammer.t => {
  open Hammer;
  let hammer = Hammer.create(canvas);

  hammer
  ->get("pan")
  ->set({"enable": true, "pointers": 2, "direction": Hammer.direction_all});
  hammer->get("pinch")->set({"enable": true, "threshold": 0.1});
  hammer->get("pinch")->recognizeWith(hammer->get("pan"));
  hammer->get("tap")->set({"enable": true, "pointers": 1});
  hammer->get("doubletap")->set({"enable": true, "pointers": 2});
  hammer
  ->add(
      Hammer.Pan.create({
        "event": "drag",
        "pointers": 1,
        "direction": Hammer.direction_all,
      }),
    );
  hammer
  ->add(
      Hammer.Rotate.create({"event": "spin", "enable": false, "pointers": 2}),
    );
  hammer->get("spin")->recognizeWith(hammer->get("tap"));
  hammer;
};

let updateListeners = (hammer: Hammer.t): unit =>
  Hammer.(
    if (dragger^.active) {
      hammer->get("pan")->set({"enable": false});
      hammer->get("pinch")->set({"enable": false});
      hammer->get("spin")->set({"enable": true});
    } else {
      hammer->get("pan")->set({"enable": true});
      hammer->get("pinch")->set({"enable": true});
      hammer->get("drag")->set({"enable": true});
      hammer->get("spin")->set({"enable": false});
    }
  );

let attach = (gi: GameInteractor.t): unit => {
  Logger.trace("attached: TouchInteractor");
  dragger := gi |> GameInteractor.defaultDragger;
  open Hammer;
  let hammer = setupHammer(gi.puzzle.stage |> Stage.canvas);

  hammer
  ->on("tap", e => {
      Logger.trace(e##"type");
      dragger := dragger^.continue(e##center);
      dragger := dragger^.attempt();
      hammer |> updateListeners;
    });

  hammer
  ->on("doubletap", e => {
      Logger.trace(e##"type");
      dragger := dragger^.finish();
      hammer |> updateListeners;
      gi.puzzle |> View.fit;
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
      mover := gi |> GameInteractor.getMover(e##center) |> Maybe.pure;
      hammer |> updateListeners;
    });
  hammer->on("panmove", e => mover^ |> Maybe.traverse_(f => f(e##center)));

  hammer
  ->on("dragstart", e => {
      Logger.trace(e##"type");
      dragger := dragger^.continue(e##center);
      hammer |> updateListeners;
    });
  hammer->on("dragmove", e => dragger^.move(e##center));
  hammer
  ->on("dragend", _ => {
      dragger := dragger^.attempt();
      hammer |> updateListeners;
    });

  hammer
  ->on("spinstart", e => {
      Logger.trace(e##"type");
      hammer->get("drag")->set({"enable": false});
      dragger^.resetSpin(e##rotation *. 3.0);
    });
  hammer->on("spinmove", e => dragger^.spin(e##rotation *. 3.0));
  hammer
  ->on("spinend", _ => {
      let _ =
        Js.Global.setTimeout(
          () => hammer->get("drag")->set({"enable": true}),
          100,
        );
      ();
    });
};
