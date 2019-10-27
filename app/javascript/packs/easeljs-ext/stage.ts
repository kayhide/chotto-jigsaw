import { Stage } from "@createjs/easeljs";

Object.defineProperties(Stage.prototype, {
  canvas: {
    get(): HTMLCanvasElement {
      return this._canvas;
    },
    set(canvas: HTMLCanvasElement): void {
      this._canvas = canvas;
    },
    enumerable: true,
    configurable: true
  }
});

Stage.prototype.invalidate = function(): void {
  this.invalidated = true;
};
