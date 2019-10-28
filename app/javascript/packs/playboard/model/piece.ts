import {
  Point,
  Rectangle,
  Matrix2D,
  Container,
  Shape
} from "@createjs/easeljs";

import Logger from "../logger";

export default class Piece {
  static pieces: Array<Piece> = [];

  id: number;
  shape: Shape = null;
  merger: Piece = null;

  // FIXME Refactor and drop the reference to Puzzle
  // Cannot type Puzzle for cyclic reference
  puzzle = null;

  loops: Array<Array<Point>> = [];
  private _position: Point = new Point();
  private _rotation = 0;

  neighborIds: Array<number>;
  private _boundary: Rectangle;

  static parse(src): Piece {
    const piece = new Piece();
    piece.id = src.number;
    piece.loops = [src.points.map(p => (p ? new Point(p[0], p[1]) : null))];
    piece.neighborIds = src.neighbors;
    Piece.pieces[piece.id] = piece;
    return piece;
  }

  static find(id): Piece {
    return Piece.pieces[id];
  }

  get position(): Point {
    return this._position;
  }

  set position(pt: Point) {
    this._position = pt;
    this._boundary = null;
  }

  get rotation(): number {
    return this._rotation;
  }

  set rotation(deg: number) {
    this._rotation = deg;
    this._boundary = null;
  }

  get matrix(): Matrix2D {
    return new Matrix2D()
      .translate(this._position.x, this._position.y)
      .rotate(this._rotation);
  }

  addLoop(lp): void {
    this.loops.push(lp);
    if (lp.piece) lp.piece.removeLoop(lp);
    lp.piece = this;
  }

  removeLoop(lp): void {
    _(this.loops).pull(lp);
  }

  getEntity(): Shape {
    if (this.merger != null) {
      return this.getMerger();
    }
    return this;
  }

  getMerger(): Shape {
    let { merger } = this;
    while (merger && merger.merger) {
      merger = merger.merger;
    }
    return merger;
  }

  isAlive(): boolean {
    return !this.merger;
  }

  findMergeableOn(point: Point): Piece {
    return this.getAdjacentPieces().find(p => this.isWithinTolerance(p, point));
  }

  isWithinTolerance(target: Piece, pt: Point): boolean {
    if (Math.abs(this.getDegreeTo(target)) < this.puzzle.rotationTolerance) {
      const pt0 = pt.apply(this.matrix.invert());
      const pt1 = pt.apply(target.matrix.invert());
      if (pt0.distanceTo(pt1) < this.puzzle.translationTolerance) {
        return true;
      }
    }
    return false;
  }

  getDegreeTo(target): number {
    const deg = (target.shape.rotation - this.shape.rotation) % 360;
    if (deg > 180) {
      return deg - 360;
    }
    if (deg <= -180) {
      return deg + 360;
    }
    return deg;
  }

  getAdjacentPieces(): Array<Piece> {
    return _(this.neighborIds)
      .map(Piece.find)
      .map(p => p.getEntity())
      .uniq()
      .value();
  }

  getLocalPoints(): Array<Point> {
    return this.loops.flatMap(lp => lp.filter(pt => pt));
  }

  getLocalBoundary(): Rectangle {
    return Point.boundary(this.getLocalPoints());
  }

  getPoints(): Array<Point> {
    const mtx = this.matrix;
    return this.getLocalPoints()
      .filter(pt => pt)
      .map(pt => pt.apply(mtx));
  }

  get boundary(): Rectangle {
    if (!this._boundary) {
      this._boundary = Point.boundary(this.getPoints());
    }
    return this._boundary;
  }

  get center(): Point {
    return this.boundary.center;
  }

  draw(): void {
    const g = this.shape.graphics;
    g.clear();
    if (this.puzzle.drawingConfig.draws_image) {
      g.beginBitmapFill(this.puzzle.image);
    } else {
      g.beginFill("#9fa");
    }
    if (this.puzzle.drawingConfig.draws_stroke) {
      g.setStrokeStyle(2).beginStroke("#f0f");
    }
    this.loops.forEach(this.drawCurve.bind(this));
    g.endFill().endStroke();

    const boundary = this.getLocalBoundary();
    if (this.puzzle.drawingConfig.draws_boundary) {
      g.setStrokeStyle(2)
        .beginStroke("#0f0")
        .rect(boundary.x, boundary.y, boundary.width, boundary.height);
    }
    if (this.puzzle.drawingConfig.draws_control_line) {
      g.setStrokeStyle(2).beginStroke("#fff");
      this.loops.forEach(this.drawPolyline.bind(this));
    }
    if (this.puzzle.drawingConfig.draws_center) {
      const { x, y } = boundary.center;
      g.setStrokeStyle(2)
        .beginFill("#390")
        .drawCircle(x, y, this.puzzle.linearMeasure / 32);
    }
    {
      const area = new Shape();
      area.graphics
        .beginFill("#000")
        .drawRect(boundary.x, boundary.y, boundary.width, boundary.height);
      this.shape.hitArea = area;
    }
    this.cache(boundary);
  }

  cache(boundary = null, scale = null): void {
    const { x, y, width, height } = (
      boundary || this.getLocalBoundary()
    ).inflate(4);
    const scale_ =
      scale || Math.min(Math.max(180 / this.puzzle.linearMeasure, 1), 4);
    this.shape.cache(x, y, width, height, scale_);
  }

  enbox(p): void {
    if (!(this.shape instanceof Container)) {
      const shape_ = this.shape;
      shape_.uncache();
      const container = new Container();
      container.copyTransform(shape_);
      shape_.clearTransform();
      shape_.parent.addChild(container);
      container.addChild(shape_);
      container.piece = this;
      this.shape = container;
    }
    p.shape.uncache();
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
    this._boundary = null;
    this.cache();
  }

  unbox(): void {
    if (this.shape instanceof Container) {
      const container = this.shape;
      this.shape = container.getChildAt(0);
      this.shape.copyTransform(container);
      container.parent.addChild(this.shape);
      container.remove();
      this.draw();
    }
  }

  drawCurve(points): void {
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

  drawPolyline(points): void {
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
