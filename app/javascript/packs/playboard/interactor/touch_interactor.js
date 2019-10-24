import Hammer from "hammerjs";

import Logger from "../logger";

export default class TouchInteractor {
  get dragger() {
    return this._dragger;
  }

  set dragger(x) {
    this._dragger = x;
    this.updateListeners();
  }

  constructor(game) {
    this.setupHammer(game);
    this.game = game;
    this.dragger = game.defaultDragger;
  }

  setupHammer(game) {
    this.mc = new Hammer(game.canvas);
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
  }

  attach() {
    this.mc.on("tap", e => {
      Logger.trace(e.type);
      this.dragger = this.dragger.end();
    });

    this.mc.on("doubletap", e => {
      Logger.trace(e.type);
      this.dragger = this.dragger.end();
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
      this.dragger = this.dragger.continue(e.center);
    });
    this.mc.on("dragmove", e => {
      this.dragger.move(e.center);
    });
    this.mc.on("dragend", e => {
      this.dragger = this.dragger.attempt();
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

  updateListeners() {
    if (this.dragger.active) {
      this.mc.get("pan").set({ enable: false });
      this.mc.get("pinch").set({ enable: false });
      this.mc.get("spin").set({ enable: true });
    } else {
      this.mc.get("pan").set({ enable: true });
      this.mc.get("pinch").set({ enable: true });
      this.mc.get("drag").set({ enable: true });
      this.mc.get("spin").set({ enable: false });
    }
  }
}
