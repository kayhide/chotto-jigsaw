import {
  Point,
  Rectangle,
  Matrix2D,
  DisplayObject,
  Stage
} from "@createjs/easeljs";

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

Object.defineProperties(Point.prototype, {
  isZero: {
    get(): boolean {
      return this.x === 0 && this.y === 0;
    },
    enumerable: true,
    configurable: true
  }
});

Rectangle.createEmpty = function(): Rectangle {
  const rect = new Rectangle();
  rect.empty = true;
  return rect;
};

Rectangle.prototype.clear = function(): Rectangle {
  this.empty = true;
  return this;
};

Rectangle.prototype.addPoint = function(pt): Rectangle {
  if (this.empty) {
    this.x = pt.x;
    this.y = pt.y;
    this.width = 0;
    this.height = 0;
    this.empty = false;
  } else {
    if (pt.x < this.x) {
      this.width += this.x - pt.x;
      this.x = pt.x;
    } else if (pt.x > this.x + this.width) {
      this.width = pt.x - this.x;
    }
    if (pt.y < this.y) {
      this.height += this.y - pt.y;
      this.y = pt.y;
    } else if (pt.y > this.y + this.height) {
      this.height = pt.y - this.y;
    }
  }
  return this;
};

Rectangle.prototype.addRectangle = function(rect: Rectangle): Rectangle {
  rect.cornerPoints.forEach(pt => this.addPoint(pt));
  return this;
};

Object.defineProperties(Rectangle.prototype, {
  topLeft: {
    get(): Point {
      return new Point(this.x, this.y);
    },
    enumerable: true,
    configurable: true
  },
  topRight: {
    get(): Point {
      return new Point(this.x + this.width, this.y);
    },
    enumerable: true,
    configurable: true
  },
  bottomLeft: {
    get(): Point {
      return new Point(this.x, this.y + this.height);
    },
    enumerable: true,
    configurable: true
  },
  bottomRight: {
    get(): Point {
      return new Point(this.x + this.width, this.y + this.height);
    },
    enumerable: true,
    configurable: true
  },
  center: {
    get(): Point {
      return new Point(this.x + this.width / 2, this.y + this.height / 2);
    },
    enumerable: true,
    configurable: true
  },
  cornerPoints: {
    get(): Array<Point> {
      return [this.topLeft, this.topRight, this.bottomLeft, this.bottomRight];
    },
    enumerable: true,
    configurable: true
  }
});

Rectangle.prototype.inflate = function(offset: number): Rectangle {
  this.x -= offset;
  this.y -= offset;
  this.width += offset * 2;
  this.height += offset * 2;
  return this;
};

Point.boundary = function(points: Array<Point>): Rectangle {
  const rect = Rectangle.createEmpty();
  points.forEach(pt => rect.addPoint(pt));
  return rect;
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

// DisplayObject
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
