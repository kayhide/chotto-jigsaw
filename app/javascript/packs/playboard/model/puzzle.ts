import {
  Shape,
  Stage,
  Container,
  Point,
  Rectangle,
  Matrix2D
} from "@createjs/easeljs";

import Piece from "./piece";
import TranslateCommand from "../command/translate_command";
import RotateCommand from "../command/rotate_command";
import * as Point_ from "../../easeljs-ext/Point.bs";

export default class Puzzle {
  stage: Stage;
  container: Container;

  image: HTMLImageElement;
  pieces: Array<Piece>;
  shape: Shape = null;

  linearMeasure: number;
  rotationTolerance: number;

  constructor(canvas: HTMLCanvasElement) {
    this.stage = new Stage(canvas);
    this.image = null;
    this.pieces = [];
    this.rotationTolerance = 24;
  }

  parse(content): void {
    this.pieces = content.pieces.map(Piece.parse);
    this.linearMeasure = content.linear_measure;
  }

  get piecesCount(): number {
    return this.pieces.length;
  }

  get translationTolerance(): number {
    return this.linearMeasure / 4;
  }

  initizlize(image): void {
    this.image = image;

    this.container = new Container();
    this.stage.addChild(this.container);

    this.shape = new Shape();
    this.container.addChild(this.shape);

    this.pieces.forEach(p => {
      p.shape = new Shape();
      p.shape.piece = p;
      this.container.addChild(p.shape);
    });
  }

  get progress(): number {
    const i = this.pieces.filter(p => !p.isAlive()).length;
    return i / (this.pieces.length - 1);
  }

  get boundary(): Rectangle {
    const rect = Rectangle.createEmpty();
    this.pieces
      .filter(p => p.isAlive())
      .forEach(p => {
        rect.addRectangle(p.boundary);
      });
    return rect;
  }

  shuffle(): void {
    const s = Math.max(this.image.width, this.image.height) * 2;
    this.pieces
      .filter(p => p.isAlive())
      .forEach(p => {
        const { x, y } = p.center;
        const center = p.shape.localToParent(x, y);
        new RotateCommand(p, center, Math.random() * 360 - 180).post();
        const vec = new Point(Math.random() * s, Math.random() * s);
        new TranslateCommand(p, Point_.subtract(center, vec)).post();
      });
  }

  get currentScale(): number {
    return this.container.scaleX;
  }

  scale(x, y, scale): void {
    const pt0 = Point_.to_(this.container, Point_.fromWindow(new Point(x, y)));
    const delta = scale / this.currentScale;
    const mtx = this.container.matrix
      .translate(pt0.x, pt0.y)
      .scale(delta, delta)
      .translate(-pt0.x, -pt0.y);
    Object.assign(this.container, mtx.decompose());
    this.stage.update();
  }

  invalidate(): void {
    this.stage.invalidate();
  }
}
