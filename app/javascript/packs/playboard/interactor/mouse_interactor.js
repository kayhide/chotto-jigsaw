import { Point } from "@createjs/easeljs";

export default class MouseInteractor {
  constructor(game) {
    this.game = game;
    this.dragger = game.defaultDragger;
  }

  attach() {
    $(this.game.canvas).on("mousewheel", e => {
      e.preventDefault();
      const e_ = e.originalEvent;
      const pt = new Point(e_.clientX, e_.clientY);
      this.dragger = this.dragger.continue(pt);

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
      if (mover) mover = null;
      else if (e.which > 0) this.dragger = this.dragger.attempt();
    });
  }
}
