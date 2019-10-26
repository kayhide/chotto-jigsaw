import Hammer from "hammerjs";

import Logger from "../logger";
import Game, { Dragger, Mover, Scaler } from "./game";

export default class TouchInteractor {
  game: Game;
  hammer: Hammer;
  _dragger: Dragger;

  get dragger(): Dragger {
    return this._dragger;
  }

  set dragger(x: Dragger) {
    this._dragger = x;
    this.updateListeners();
  }

  constructor(game) {
    this.setupHammer(game);
    this.game = game;
    this.dragger = game.defaultDragger;
  }

  setupHammer(game): void {
    this.hammer = new Hammer(game.canvas);
    this.hammer
      .get("pan")
      .set({ enable: true, pointers: 2, direction: Hammer.DIRECTION_ALL });
    this.hammer.get("pinch").set({ enable: true, threshold: 0.1 });
    this.hammer.get("pinch").recognizeWith(this.hammer.get("pan"));
    this.hammer.get("tap").set({ enable: true, pointers: 1 });
    this.hammer.get("doubletap").set({ enable: true, pointers: 2 });
    this.hammer.add(
      new Hammer.Pan({
        event: "drag",
        pointers: 1,
        direction: Hammer.DIRECTION_ALL
      })
    );
    this.hammer.add(
      new Hammer.Pan({
        event: "spin",
        enable: false,
        pointers: 2,
        direction: Hammer.DIRECTION_ALL
      })
    );
    this.hammer.get("spin").recognizeWith(this.hammer.get("tap"));
  }

  attach(): void {
    this.hammer.on("tap", e => {
      Logger.trace(e.type);
      this.dragger = this.dragger.end();
    });

    this.hammer.on("doubletap", e => {
      Logger.trace(e.type);
      this.dragger = this.dragger.end();
      this.game.fit();
    });

    {
      let scaler: Scaler = null;
      this.hammer.on("pinchstart", e => {
        Logger.trace(e.type);
        scaler = this.game.getScaler();
      });
      this.hammer.on("pinchmove", e => {
        if (scaler) scaler(e.center, e.scale);
      });
    }

    {
      let mover: Mover = null;
      this.hammer.on("panstart", e => {
        Logger.trace(e.type);
        mover = this.game.getMover(e.center);
      });
      this.hammer.on("panmove", e => {
        if (mover) mover(e.center);
      });
    }

    this.hammer.on("dragstart", e => {
      Logger.trace(e.type);
      this.dragger = this.dragger.continue(e.center);
    });
    this.hammer.on("dragmove", e => {
      this.dragger.move(e.center);
    });
    this.hammer.on("dragend", e => {
      this.dragger = this.dragger.attempt();
    });

    this.hammer.on("spinstart", e => {
      Logger.trace(e.type);
      this.hammer.get("drag").set({ enable: false });
      this.dragger.resetSpin();
    });
    this.hammer.on("spinmove", e => {
      this.dragger.spin(e.deltaY);
    });
    this.hammer.on("spinend", () => {
      window.setTimeout(() => {
        this.hammer.get("drag").set({ enable: true });
      }, 100);
    });
  }

  updateListeners(): void {
    if (this.dragger.active) {
      this.hammer.get("pan").set({ enable: false });
      this.hammer.get("pinch").set({ enable: false });
      this.hammer.get("spin").set({ enable: true });
    } else {
      this.hammer.get("pan").set({ enable: true });
      this.hammer.get("pinch").set({ enable: true });
      this.hammer.get("drag").set({ enable: true });
      this.hammer.get("spin").set({ enable: false });
    }
  }
}
