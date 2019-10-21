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
import Command from "../command/command";
import TranslateCommand from "../command/translate_command";
import RotateCommand from "../command/rotate_command";
import MergeCommand from "../command/merge_command";

export default class Puzzle {
  constructor(canvas) {
    this.stage = new Stage(canvas);
    this.image = null;
    this.pieces = [];
    this.rotation_tolerance = 24;
    this.translation_tolerance = 0;
    this.drawing_config = new DrawingConfig();
  }

  parse(content) {
    this.pieces = content.pieces.map(Piece.parse);
    this.piece_count = this.pieces.length;
    this.linear_measure = content.linear_measure;
    this.translation_tolerance = content.linear_measure / 4;
    return this;
  }

  initizlize(image) {
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

    this.foreground = new Container();
    this.stage.addChild(this.foreground);

    Command.onPost.unshift(cmd => {
      if (cmd instanceof MergeCommand) {
        this.updateProgress();
      }
    });
  }

  buildGuide() {
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

  toggleGuide() {
    this.wrapperGuide.visible = !this.wrapperGuide.visible;
    this.containerGuide.visible = !this.containerGuide.visible;
    this.invalidate();
  }

  updateProgress() {
    const i = this.pieces.filter(p => !p.isAlive()).length;
    this.progress = i / (this.pieces.length - 1);
  }

  getBoundary() {
    const rect = Rectangle.createEmpty();
    this.pieces
      .filter(p => p.isAlive())
      .forEach(p => {
        rect.addRectangle(p.getBoundary());
      });
    return rect;
  }

  shuffle() {
    const s = Math.max(this.image.width, this.image.height) * 2;
    this.pieces
      .filter(p => p.isAlive())
      .forEach(p => {
        const { x, y } = p.getCenter();
        const center = p.shape.localToParent(x, y);
        new RotateCommand(p, center, Math.random() * 360).post();
        const vec = new Point(Math.random() * s, Math.random() * s);
        new TranslateCommand(p, vec.subtract(center)).post();
      });
  }

  zoom(x, y, scale) {
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

  get currentScale() {
    return this.container.scaleX;
  }

  scale(x, y, scale) {
    const pt0 = new Point(x, y).fromWindow().to(this.container);
    const delta = scale / this.currentScale;
    const mtx = this.container
      .matrix()
      .translate(pt0.x, pt0.y)
      .scale(delta, delta)
      .translate(-pt0.x, -pt0.y);
    Object.assign(this.container, mtx.decompose());
    this.stage.update();
  }

  invalidate() {
    this.stage.invalidate();
  }
}
