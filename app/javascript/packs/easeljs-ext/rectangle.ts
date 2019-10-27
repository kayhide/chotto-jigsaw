import { Point, Rectangle } from "@createjs/easeljs";

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

Rectangle.createEmpty = function(): Rectangle {
  const rect = new Rectangle();
  rect.empty = true;
  return rect;
};

Rectangle.prototype.clear = function(): Rectangle {
  this.empty = true;
  return this;
};

Rectangle.prototype.addPoint = function({ x, y }: Point): Rectangle {
  if (this.empty) {
    this.x = x;
    this.y = y;
    this.width = 0;
    this.height = 0;
    this.empty = false;
  } else {
    if (x < this.x) {
      this.width += this.x - x;
      this.x = x;
    } else if (x > this.x + this.width) {
      this.width = x - this.x;
    }
    if (y < this.y) {
      this.height += this.y - y;
      this.y = y;
    } else if (y > this.y + this.height) {
      this.height = y - this.y;
    }
  }
  return this;
};

Rectangle.prototype.addRectangle = function(rect: Rectangle): Rectangle {
  rect.cornerPoints.forEach(this.addPoint.bind(this));
  return this;
};

Rectangle.prototype.inflate = function(offset: number): Rectangle {
  this.x -= offset;
  this.y -= offset;
  this.width += offset * 2;
  this.height += offset * 2;
  return this;
};
