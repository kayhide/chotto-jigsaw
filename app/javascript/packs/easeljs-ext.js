import { Point, Rectangle, DisplayObject, Stage } from "@createjs/easeljs";

Point.prototype.add = function(p) {
  return new Point(this.x + p.x, this.y + p.y);
};

Point.prototype.subtract = function(p) {
  return new Point(this.x - p.x, this.y - p.y);
};

Point.prototype.scale = function(d) {
  return new Point(this.x * d, this.y * d);
};

Point.prototype.apply = function(mtx) {
  return mtx.transformPoint(this.x, this.y);
};

Point.prototype.distanceTo = function(pt) {
  return Math.sqrt((pt.x - this.x) ** 2 + (pt.y - this.y) ** 2);
};

Point.prototype.isZero = function() {
  return this.x === 0 && this.y === 0;
};

Rectangle.createEmpty = function() {
  const rect = new Rectangle();
  rect.empty = true;
  return rect;
};

Rectangle.prototype.clear = function() {
  this.empty = true;
  return this;
};

Rectangle.prototype.addPoint = function(pt) {
  if (this.empty) {
    this.x = pt.x;
    this.y = pt.y;
    this.width = 0;
    this.height = 0;
    this.empty = false;
    this.points = [pt];
  } else {
    this.points.push(pt);
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

Rectangle.prototype.addRectangle = function(rect) {
  rect.getCornerPoints().forEach(pt => this.addPoint(pt));
  return this;
};

Rectangle.prototype.getTopLeft = function() {
  return new Point(this.x, this.y);
};

Rectangle.prototype.getTopRight = function() {
  return new Point(this.x + this.width, this.y);
};

Rectangle.prototype.getBottomLeft = function() {
  return new Point(this.x, this.y + this.height);
};

Rectangle.prototype.getBottomRight = function() {
  return new Point(this.x + this.width, this.y + this.height);
};

Rectangle.prototype.getCornerPoints = function() {
  return [
    this.getTopLeft(),
    this.getTopRight(),
    this.getBottomLeft(),
    this.getBottomRight()
  ];
};

Rectangle.prototype.getCenter = function() {
  return new Point(this.x + this.width / 2, this.y + this.height / 2);
};

Rectangle.prototype.inflate = function(offset) {
  this.x -= offset;
  this.y -= offset;
  this.width += offset * 2;
  this.height += offset * 2;
  return this;
};

Point.boundary = function(points) {
  const rect = Rectangle.createEmpty();
  points.forEach(pt => rect.addPoint(pt));
  return rect;
};

Point.prototype.toArray = function() {
  return [this.x, this.y];
};

Point.prototype.from = function(obj) {
  const pt = this.clone();
  pt.on = obj;
  return pt;
};

Point.prototype.to = function(obj) {
  let pt = null;
  if (this.on != null) {
    if (this.on.getRoot() === obj.getRoot()) {
      if (this.on_global) {
        pt = obj.globalToLocal(this.x, this.y);
      } else {
        pt = this.on.localToLocal(this.x, this.y, obj);
      }
    } else if (this.on_global) {
      pt = this.on.globalToWindow(this.x, this.y);
      pt = obj.windowToLocal(pt.x, pt.y);
    } else {
      pt = this.on.localToWindow(this.x, this.y);
      pt = obj.windowToLocal(pt.x, pt.y);
    }
  } else if (this.on_window) {
    pt = obj.windowToLocal(this.x, this.y);
  } else {
    pt = obj.globalToLocal(this.x, this.y);
  }
  pt.on = obj;
  pt.on_global = null;
  pt.on_window = null;
  return pt;
};

Point.prototype.toGlobal = function() {
  let pt = null;
  if (this.on && !this.on_window && !this.on_global) {
    pt = this.on.localToGlobal(this.x, this.y);
    pt.on_global = true;
  } else {
    pt = this.clone();
    pt.on_window = null;
  }
  return pt;
};

Point.prototype.fromWindow = function() {
  const pt = this.clone();
  pt.on_global = null;
  pt.on_window = true;
  return pt;
};

Point.prototype.toWindow = function() {
  let pt = null;
  if (this.on) {
    if (this.on_global) {
      pt = this.on.globalToWindow(this.x, this.y);
    } else {
      pt = this.on.localToWindow(this.x, this.y);
    }
  } else {
    pt = this.clone();
  }
  pt.on = null;
  pt.on_global = null;
  pt.on_window = true;
  return pt;
};

DisplayObject.prototype.remove = function() {
  if (this.parent) this.parent.removeChild(this);
};

DisplayObject.prototype.position = function() {
  return new Point(this.x, this.y);
};

DisplayObject.prototype.localToParent = function(x, y) {
  return this.localToLocal(x, y, this.parent);
};

DisplayObject.prototype.copyTransform = function(src) {
  this.x = src.x;
  this.y = src.y;
  this.scaleX = src.scaleX;
  this.scaleY = src.scaleY;
  this.rotation = src.rotation;
};

DisplayObject.prototype.clearTransform = function() {
  this.setTransform();
};

DisplayObject.prototype.projectTo = function(dst) {
  const pt0 = this.localToWindow(0, 0);
  const pt1 = dst.windowToLocal(pt0.x, pt0.y);
  this.x = pt1.x;
  this.y = pt1.y;
  dst.addChild(this);
};

DisplayObject.prototype.getRoot = function() {
  let obj = this;
  while (obj.parent) {
    obj = obj.parent;
  }
  return obj;
};

DisplayObject.prototype.getCanvas = function() {
  const root_ = this.getRoot();
  return root_ ? root_.canvas : null;
};

DisplayObject.prototype.localToWindow = function(x, y) {
  const pt0 = $(this.getCanvas()).position();
  const pt = this.localToGlobal(x, y);
  pt.x += pt0.left;
  pt.y += pt0.top;
  return pt;
};

DisplayObject.prototype.windowToLocal = function(x, y) {
  const pt0 = $(this.getCanvas()).position();
  const pt = this.globalToLocal(x - pt0.left, y - pt0.top);
  return pt;
};

DisplayObject.prototype.globalToWindow = function(x, y) {
  const pt0 = $(this.getCanvas()).position();
  return new Point(x + pt0.left, y + pt0.top);
};

DisplayObject.prototype.windowToGlobal = function(x, y) {
  const pt0 = $(this.getCanvas()).position();
  return new Point(x - pt0.left, y - pt0.top);
};

Stage.prototype.invalidate = function() {
  this.invalidated = true;
};
