import Hammer from "hammerjs";

import Logger from "../logger";
import Game from "./game";

export default class TouchInteractor {
  constructor(game) {
    this.game = game;
    this.dragger = Game.default_dragger;
  }

  attach() {
    this.mc = new Hammer(this.game.canvas);
    this.mc
      .get("pan")
      .set({ enable: true, pointers: 2, direction: Hammer.DIRECTION_ALL });
    this.mc.get("pinch").set({ enable: true, threshold: 0.1 });
    this.mc.get("pinch").recognizeWith(this.mc.get("pan"));
    this.mc.get("tap").set({ enable: true, pointers: 1 });
    this.mc.get("doubletap").set({ enable: true, pointers: 2 });
    this.mc.add(
      new Hammer.Pan({
        event: "drag",
        pointers: 1,
        direction: Hammer.DIRECTION_ALL
      })
    );
    this.mc.add(
      new Hammer.Pan({
        event: "spin",
        enable: false,
        pointers: 2,
        direction: Hammer.DIRECTION_ALL
      })
    );
    this.mc.get("spin").recognizeWith(this.mc.get("tap"));

    this.mc.on("tap", e => {
      Logger.trace(e.type);
      this.dragEnd();
    });

    this.mc.on("doubletap", e => {
      Logger.trace(e.type);
      this.dragEnd();
      this.game.fit();
    });

    {
      let scaler = null;
      this.mc.on("pinchstart", e => {
        Logger.trace(e.type);
        scaler = this.game.getScaler();
      });
      this.mc.on("pinchmove", e => {
        if (scaler) scaler(e.center, e.scale);
      });
    }

    {
      let mover = null;
      this.mc.on("panstart", e => {
        Logger.trace(e.type);
        mover = this.game.getMover(e.center);
      });
      this.mc.on("panmove", e => {
        if (mover) mover(e.center);
      });
    }

    this.mc.on("dragstart", e => {
      Logger.trace(e.type);
      this.dragStart(e.center);
    });
    this.mc.on("dragmove", e => {
      this.dragger.move(e.center);
    });

    this.mc.on("spinstart", e => {
      Logger.trace(e.type);
      this.mc.get("drag").set({ enable: false });
      this.dragger.resetSpin();
    });
    this.mc.on("spinmove", e => {
      this.dragger.spin(e.deltaY);
    });
    this.mc.on("spinend", () => {
      window.setTimeout(() => {
        this.mc.get("drag").set({ enable: true });
      }, 100);
    });
  }

  dragStart(pt) {
    this.dragEnd();
    this.dragger = this.game.dragStart(pt);
    if (this.dragger.active) {
      this.mc.get("pan").set({ enable: false });
      this.mc.get("pinch").set({ enable: false });
      this.mc.get("spin").set({ enable: true });
    }
  }

  dragEnd() {
    if (this.dragger.active) {
      this.dragger = this.dragger.end();
      this.mc.get("pan").set({ enable: true });
      this.mc.get("pinch").set({ enable: true });
      this.mc.get("drag").set({ enable: true });
      this.mc.get("spin").set({ enable: false });
    }
  }
}
