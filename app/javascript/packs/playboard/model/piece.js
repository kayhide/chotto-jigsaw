import { Point, Matrix2D, Container } from "@createjs/easeljs";

export default class Piece {
  static parse(src) {
    const piece = new Piece();
    piece.id = src.number;
    piece.loops = [src.points.map(p => (p ? new Point(p[0], p[1]) : null))];
    piece.neighbor_ids = src.neighbors;
    Piece.pieces[piece.id] = piece;
    return piece;
  }

  static find(id) {
    return Piece.pieces[id];
  }

  constructor() {
    this.loops = [];
    this.shape = null;
    this.merger = null;
    this._position = new Point();
    this._rotation = 0;
    this.drawing_config = null;
  }

  position(pt) {
    if (pt != null) {
      this._position = pt;
      this.boundary = null;
      return this;
    }
    return this._position;
  }

  rotation(deg) {
    if (deg != null) {
      this._rotation = deg;
      this.boundary = null;
      return this;
    }
    return this._rotation;
  }

  matrix() {
    return new Matrix2D()
      .translate(this._position.x, this._position.y)
      .rotate(this._rotation);
  }

  addLoop(lp) {
    this.loops.push(lp);
    if (lp.piece) lp.piece.removeLoop(lp);
    lp.piece = this;
  }

  removeLoop(lp) {
    _(this.loops).pull(lp);
  }

  getEntity() {
    if (this.merger != null) {
      return this.getMerger();
    }
    return this;
  }

  getMerger() {
    let { merger } = this;
    while (merger && merger.merger) {
      merger = merger.merger;
    }
    return merger;
  }

  isAlive() {
    return !this.merger;
  }

  findMergeableOn(point) {
    return this.getAdjacentPieces().find(p => this.isWithinTolerance(p, point));
  }

  isWithinTolerance(target, pt) {
    if (Math.abs(this.getDegreeTo(target)) < this.puzzle.rotation_tolerance) {
      const pt0 = pt.apply(this.matrix().invert());
      const pt1 = pt.apply(target.matrix().invert());
      if (pt0.distanceTo(pt1) < this.puzzle.translation_tolerance) {
        return true;
      }
    }
    return false;
  }

  getDegreeTo(target) {
    const deg = (target.shape.rotation - this.shape.rotation) % 360;
    if (deg > 180) {
      return deg - 360;
    }
    if (deg <= -180) {
      return deg + 360;
    }
    return deg;
  }

  getAdjacentPieces() {
    return _(this.neighbor_ids)
      .map(Piece.find)
      .map(p => p.getEntity())
      .uniq()
      .value();
  }

  getLocalPoints() {
    return this.loops.flatMap(lp => lp.filter(pt => pt));
  }

  getLocalBoundary() {
    return Point.boundary(this.getLocalPoints());
  }

  getPoints() {
    const mtx = this.matrix();
    return this.getLocalPoints()
      .filter(pt => pt)
      .map(pt => pt.apply(mtx));
  }

  getBoundary() {
    if (!this.boundary) {
      this.boundary = Point.boundary(this.getPoints());
    }
    return this.boundary;
  }

  getCenter() {
    return this.getBoundary().getCenter();
  }

  draw() {
    this.shape.uncache();
    const g = this.shape.graphics;
    g.clear();
    if (this.puzzle.drawing_config.draws_image) {
      g.beginBitmapFill(this.puzzle.image);
    } else {
      g.beginFill("#9fa");
    }
    if (this.puzzle.drawing_config.draws_stroke) {
      g.setStrokeStyle(2).beginStroke("#f0f");
    }
    this.loops.forEach(this.drawCurve.bind(this));
    g.endFill().endStroke();
    const boundary = this.getLocalBoundary();
    if (this.puzzle.drawing_config.draws_boundary) {
      g.setStrokeStyle(2)
        .beginStroke("#0f0")
        .rect(boundary.x, boundary.y, boundary.width, boundary.height);
    }
    if (this.puzzle.drawing_config.draws_control_line) {
      g.setStrokeStyle(2).beginStroke("#fff");
      this.loops.forEach(this.drawPolyline.bind(this));
    }
    if (this.puzzle.drawing_config.draws_center) {
      const center = boundary.getCenter();
      g.setStrokeStyle(2)
        .beginFill("#390")
        .drawCircle(center.x, center.y, this.puzzle.linear_measure / 32);
    }
  }

  cache(padding = 0) {
    const boundary = this.getLocalBoundary();
    return this.shape.cache(
      boundary.x - padding,
      boundary.y - padding,
      boundary.width + padding * 2,
      boundary.height + padding * 2
    );
  }

  uncache() {
    return this.shape.uncache();
  }

  enbox(p) {
    if (!(this.shape instanceof Container)) {
      const shape_ = this.shape;
      const container = new Container();
      container.copyTransform(shape_);
      shape_.clearTransform();
      shape_.parent.addChild(container);
      container.addChild(shape_);
      container.piece = this;
      this.shape = container;
    }
    if (p) {
      if (p.shape instanceof Container) {
        while (p.shape.numChildren > 0) {
          const s = p.shape.getChildAt(0);
          this.shape.addChild(s);
        }
        p.shape.remove();
      } else {
        p.shape.clearTransform();
        this.shape.addChild(p.shape);
      }
    }
    this.boundary = null;
  }

  unbox() {
    if (this.shape instanceof Container) {
      const container = this.shape;
      this.shape = container.getChildAt(0);
      this.shape.copyTransform(container);
      container.parent.addChild(this.shape);
      container.remove();
      this.draw();
    }
  }

  drawCurve(points) {
    const g = this.shape.graphics;
    g.moveTo(points[0].x, points[0].y);

    _(points)
      .drop(1)
      .chunk(3)
      .forEach(pts => {
        if (pts[0] && pts[1]) {
          g.bezierCurveTo(
            pts[0].x,
            pts[0].y,
            pts[1].x,
            pts[1].y,
            pts[2].x,
            pts[2].y
          );
        } else {
          g.lineTo(...pts[2].toArray());
        }
      });
  }

  drawPolyline(points) {
    const g = this.shape.graphics;
    g.moveTo(points[0].x, points[0].y);

    _(points)
      .drop(1)
      .forEach(pt => {
        if (pt != null) {
          g.lineTo(pt.x, pt.y);
        }
      });
  }
}

Piece.pieces = [];
