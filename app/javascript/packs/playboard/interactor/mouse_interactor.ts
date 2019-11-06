import { Point } from "@createjs/easeljs";

import * as Logger from "../../common/Logger.bs";
import Game, { Dragger, Mover } from "./game";

export default class MouseInteractor {
  game: Game;
  dragger: Dragger;

  constructor(game) {
    this.game = game;
    this.dragger = game.defaultDragger;
  }

  attach(): void {
    $(this.game.canvas).on("wheel", e => {
      e.preventDefault();
      const e_ = e.originalEvent as WheelEvent;
      const pt = new Point(e_.clientX, e_.clientY);
      this.dragger = this.dragger.continue(pt);

      if (this.dragger.active) {
        const delta = -e_.deltaY;
        this.dragger.resetSpin(0);
        this.dragger.spin(delta);
      } else {
        const delta = e_.deltaY < 0 ? 1.02 : 1 / 1.02;
        this.game.getScaler()(e_, delta);
      }
    });

    let mover: Mover = null;
    $(this.game.canvas).on("mousedown", e => {
      Logger.trace(e.type);
      e.preventDefault();
      const pt = new Point(e.offsetX, e.offsetY);
      this.dragger = this.dragger.continue(pt);
      if (!this.dragger.active) mover = this.game.getMover(pt);
    });

    $(this.game.canvas).on("mousemove", e => {
      const pt = new Point(e.offsetX, e.offsetY);
      if (mover) mover(pt);
      else if (e.which > 0) this.dragger.move(pt);
    });

    $(this.game.canvas).on("mouseup", e => {
      Logger.trace(e.type);
      if (mover) mover = null;
      else if (e.which > 0) this.dragger = this.dragger.attempt();
    });
  }
}
