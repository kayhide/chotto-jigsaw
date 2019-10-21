import { Point } from "@createjs/easeljs";

import Game from "./game";

export default class MouseInteractor {
  constructor(game) {
    this.game = game;
    this.dragger = Game.default_dragger;
  }

  attach() {
    $(this.game.canvas).on("mousewheel", e => {
      e.preventDefault();
      this.dragger = this.dragger.end();

      const e_ = e.originalEvent;
      const pt = new Point(e_.clientX, e_.clientY);
      this.dragger = this.game.dragStart(pt);

      if (this.dragger.active) {
        const delta = e_.wheelDelta / 10;
        this.dragger.resetSpin();
        this.dragger.spin(delta);
      } else {
        const delta = e_.wheelDelta > 0 ? 1.05 : 1 / 1.05;
        this.game.getScaler()(e_, delta);
      }
    });

    let mover = null;
    $(this.game.canvas).on("mousedown", e => {
      e.preventDefault();
      this.dragger.end();

      const pt = new Point(e.offsetX, e.offsetY);
      this.dragger = this.game.dragStart(pt);
      if (!this.dragger.active) mover = this.game.getMover(pt);
    });

    $(this.game.canvas).on("mousemove", e => {
      const pt = new Point(e.offsetX, e.offsetY);
      if (mover) mover(pt);
      else if (e.which > 0) this.dragger.move(pt);
    });

    $(this.game.canvas).on("mouseup", () => {
      mover = null;
    });
  }
}
