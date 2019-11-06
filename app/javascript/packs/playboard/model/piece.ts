import {
  Point,
  Rectangle,
  Matrix2D,
  Container,
  Shape
} from "@createjs/easeljs";

import * as Logger from "../../common/Logger.bs";
import * as Point_ from "../../easeljs-ext/Point.bs";
import * as Rectangle_ from "../../easeljs-ext/Rectangle.bs";

export default class Piece {
  static pieces: Array<Piece> = [];

  id: number;
  shape: Shape = null;
  private _merger: Piece = null;

  loops: Array<Array<Point>> = [];
  private _position: Point = new Point();
  private _rotation = 0;

  neighborIds: Array<number>;

  private _localBoundary: Rectangle;
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

  get localPoints(): Array<Point> {
    return this.loops.flatMap(lp => lp.filter(pt => pt));
  }

  get localBoundary(): Rectangle {
    if (!this._localBoundary) {
      this._localBoundary = Rectangle_.fromPoints(this.localPoints);
    }
    return this._localBoundary;
  }

  addLoop(lp): void {
    this.loops.push(lp);
    if (lp.piece) lp.piece.removeLoop(lp);
    lp.piece = this;
  }

  removeLoop(lp): void {
    _(this.loops).pull(lp);
  }

  get entity(): Piece {
    return this.merger || this;
  }

  get merger(): Piece {
    let merger = this._merger;
    while (merger && merger._merger) {
      merger = merger._merger;
    }
    return merger;
  }

  set merger(p: Piece) {
    this._merger = p;
  }

  isAlive(): boolean {
    return !this.merger;
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
      .map(p => p.entity)
      .uniq()
      .value();
  }

  get points(): Array<Point> {
    const mtx = this.matrix;
    return this.localPoints.filter(pt => pt).map(pt => Point_.apply(mtx, pt));
  }

  get boundary(): Rectangle {
    if (!this._boundary) {
      this._boundary = Rectangle_.fromPoints(this.points);
    }
    return this._boundary;
  }

  get center(): Point {
    return Rectangle_.center(this.boundary);
  }

  cache(scale = 1): void {
    const { x, y, width, height } = Rectangle_.inflate(4, this.localBoundary);
    this.shape.cache(x, y, width, height, scale);
  }

  enbox(p): void {
    if (!(this.shape instanceof Container)) {
      const shape_ = this.shape;
      // shape_.uncache();
      const container = new Container();
      container.copyTransform(shape_);
      shape_.clearTransform();
      shape_.parent.addChild(container);
      container.addChild(shape_);
      container.piece = this;
      this.shape = container;
    }
    // p.shape.uncache();
    this.localBoundary.addRectangle(p.localBoundary);
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
    // this.cache();
  }

  unbox(): void {
    if (this.shape instanceof Container) {
      const container = this.shape;
      this.shape = container.getChildAt(0);
      this.shape.copyTransform(container);
      container.parent.addChild(this.shape);
      container.remove();
    }
  }
}
