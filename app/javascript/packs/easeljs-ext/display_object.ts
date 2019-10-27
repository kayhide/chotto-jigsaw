import { Point, Matrix2D, DisplayObject } from "@createjs/easeljs";

Object.defineProperties(DisplayObject.prototype, {
  position: {
    get(): Point {
      return new Point(this.x, this.y);
    },
    enumerable: true,
    configurable: true
  },
  matrix: {
    get(): Matrix2D {
      return new Matrix2D().appendTransform(
        this.x,
        this.y,
        this.scaleX,
        this.scaleY,
        this.rotation
      );
    },
    enumerable: true,
    configurable: true
  },
  root: {
    get(): DisplayObject {
      return this.parent ? this.parent.root : this;
    },
    enumerable: true,
    configurable: true
  },
  canvas: {
    get(): HTMLCanvasElement {
      return this._canvas
        ? this._canvas
        : this.parent
        ? this.parent.canvas
        : null;
    },
    enumerable: true,
    configurable: true
  }
});

DisplayObject.prototype.getCanvas = function(): HTMLCanvasElement {
  const root_ = this.root;
  return root_ ? root_.canvas : null;
};

DisplayObject.prototype.remove = function(): void {
  if (this.parent) this.parent.removeChild(this);
};

DisplayObject.prototype.localToParent = function(x: number, y: number): Point {
  return this.localToLocal(x, y, this.parent);
};

DisplayObject.prototype.copyTransform = function(src: DisplayObject): void {
  this.x = src.x;
  this.y = src.y;
  this.scaleX = src.scaleX;
  this.scaleY = src.scaleY;
  this.rotation = src.rotation;
};

DisplayObject.prototype.clearTransform = function(): void {
  this.setTransform();
};

DisplayObject.prototype.projectTo = function(dst: DisplayObject): void {
  const pt0 = this.localToWindow(0, 0);
  const pt1 = dst.windowToLocal(pt0.x, pt0.y);
  this.x = pt1.x;
  this.y = pt1.y;
  dst.addChild(this);
};

DisplayObject.prototype.localToWindow = function(x, y): Point {
  const pt0 = $(this.getCanvas()).position();
  const pt = this.localToGlobal(x, y);
  pt.x += pt0.left;
  pt.y += pt0.top;
  return pt;
};

DisplayObject.prototype.windowToLocal = function(x, y): Point {
  const pt0 = $(this.getCanvas()).position();
  const pt = this.globalToLocal(x - pt0.left, y - pt0.top);
  return pt;
};

DisplayObject.prototype.globalToWindow = function(x, y): Point {
  const pt0 = $(this.getCanvas()).position();
  return new Point(x + pt0.left, y + pt0.top);
};

DisplayObject.prototype.windowToGlobal = function(x, y): Point {
  const pt0 = $(this.getCanvas()).position();
  return new Point(x - pt0.left, y - pt0.top);
};
