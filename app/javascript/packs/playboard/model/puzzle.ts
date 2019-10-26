import {
  Shape,
  Stage,
  Container,
  Point,
  Rectangle,
  Matrix2D
} from "@createjs/easeljs";

import Piece from "./piece";
import DrawingConfig from "./drawing_config";
import TranslateCommand from "../command/translate_command";
import RotateCommand from "../command/rotate_command";

export default class Puzzle {
  stage: Stage;
  container: Container;
  wrapper: Container;

  image: HTMLImageElement;
  pieces: Array<Piece>;
  drawingConfig: DrawingConfig;

  linearMeasure: number;
  rotationTolerance: number;

  containerGuide: Shape;
  wrapperGuide: Shape;

  constructor(canvas: HTMLCanvasElement) {
    this.stage = new Stage(canvas);
    this.image = null;
    this.pieces = [];
    this.rotationTolerance = 24;
    this.drawingConfig = new DrawingConfig();
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
    this.wrapper = new Container();
    this.stage.addChild(this.wrapper);

    this.container = new Container();
    this.wrapper.addChild(this.container);

    this.buildGuide();

    this.pieces.forEach(p => {
      p.puzzle = this;
      p.shape = new Shape();
      p.shape.piece = p;
      p.draw();
      this.container.addChild(p.shape);
    });
  }

  buildGuide(): void {
    {
      const guide = new Shape();
      guide.graphics
        .setStrokeStyle(1)
        .beginStroke("rgba(127,255,255,0.7)")
        .beginFill("rgba(127,255,255,0.5)")
        .drawCircle(0, 0, 5);
      guide.visible = false;
      this.wrapper.addChild(guide);
      this.wrapperGuide = guide;
    }
    {
      const guide = new Shape();
      guide.graphics.setStrokeStyle(1).beginStroke("rgba(127,255,255,0.7)");
      for (let i = 0; i < 6; i += 1) {
        guide.graphics
          .moveTo(0, i * 100)
          .lineTo(500, i * 100)
          .moveTo(i * 100, 0)
          .lineTo(i * 100, 500);
      }
      guide.visible = false;
      this.container.addChild(guide);
      this.containerGuide = guide;
    }
  }

  toggleGuide(): void {
    this.wrapperGuide.visible = !this.wrapperGuide.visible;
    this.containerGuide.visible = !this.containerGuide.visible;
    this.invalidate();
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
        new RotateCommand(p, center, Math.random() * 360).post();
        const vec = new Point(Math.random() * s, Math.random() * s);
        new TranslateCommand(p, vec.subtract(center)).post();
      });
  }

  zoom(x, y, scale): void {
    this.container.scaleX = this.container.scaleX * scale;
    this.container.scaleY = this.container.scaleX;
    const pt0 = new Point(x, y).fromWindow().to(this.wrapper);
    const mtx = new Matrix2D()
      .translate(pt0.x, pt0.y)
      .scale(scale, scale)
      .translate(-pt0.x, -pt0.y);
    const pt1 = this.container.position().apply(mtx);
    this.container.x = pt1.x;
    this.container.y = pt1.y;
    this.stage.update();
  }

  get currentScale(): number {
    return this.container.scaleX;
  }

  scale(x, y, scale): void {
    const pt0 = new Point(x, y).fromWindow().to(this.container);
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
