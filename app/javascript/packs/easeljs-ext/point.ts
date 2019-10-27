import { Point, Rectangle, Matrix2D, DisplayObject } from "@createjs/easeljs";

Point.boundary = function(points: Array<Point>): Rectangle {
  const rect = Rectangle.createEmpty();
  points.forEach(pt => rect.addPoint(pt));
  return rect;
};

Object.defineProperties(Point.prototype, {
  isZero: {
    get(): boolean {
      return this.x === 0 && this.y === 0;
    },
    enumerable: true,
    configurable: true
  }
});

Point.prototype.add = function({ x, y }: Point): Point {
  return new Point(this.x + x, this.y + y);
};

Point.prototype.subtract = function({ x, y }: Point): Point {
  return new Point(this.x - x, this.y - y);
};

Point.prototype.scale = function(d: number): Point {
  return new Point(this.x * d, this.y * d);
};

Point.prototype.apply = function(mtx: Matrix2D): Point {
  return mtx.transformPoint(this.x, this.y);
};

Point.prototype.distanceTo = function({ x, y }: Point): number {
  return Math.sqrt((this.x - x) ** 2 + (this.y - y) ** 2);
};

Point.prototype.toArray = function(): Array<number> {
  return [this.x, this.y];
};

Point.prototype.from = function(obj: DisplayObject): Point {
  const pt = this.clone();
  pt.on = obj;
  return pt;
};

Point.prototype.to = function(obj: DisplayObject): Point {
  let pt = null;
  if (this.on != null) {
    if (this.on.root === obj.root) {
      if (this.onGlobal) {
        pt = obj.globalToLocal(this.x, this.y);
      } else {
        pt = this.on.localToLocal(this.x, this.y, obj);
      }
    } else if (this.onGlobal) {
      pt = this.on.globalToWindow(this.x, this.y);
      pt = obj.windowToLocal(pt.x, pt.y);
    } else {
      pt = this.on.localToWindow(this.x, this.y);
      pt = obj.windowToLocal(pt.x, pt.y);
    }
  } else if (this.onWindow) {
    pt = obj.windowToLocal(this.x, this.y);
  } else {
    pt = obj.globalToLocal(this.x, this.y);
  }
  pt.on = obj;
  pt.onGlobal = false;
  pt.onWindow = false;
  return pt;
};

Point.prototype.toGlobal = function(): Point {
  let pt = null;
  if (this.on && !this.onWindow && !this.onGlobal) {
    pt = this.on.localToGlobal(this.x, this.y);
    pt.onGlobal = true;
  } else {
    pt = this.clone();
    pt.onWindow = false;
  }
  return pt;
};

Point.prototype.fromWindow = function(): Point {
  const pt = this.clone();
  pt.onGlobal = false;
  pt.onWindow = true;
  return pt;
};

Point.prototype.toWindow = function(): Point {
  let pt = null;
  if (this.on) {
    if (this.onGlobal) {
      pt = this.on.globalToWindow(this.x, this.y);
    } else {
      pt = this.on.localToWindow(this.x, this.y);
    }
  } else {
    pt = this.clone();
  }
  pt.on = null;
  pt.onGlobal = false;
  pt.onWindow = true;
  return pt;
};
