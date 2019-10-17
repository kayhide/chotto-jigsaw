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

  centerize() {
    const rect = this.getBoundary();
    const { scaleX: sx, scaleY: sy } = this.container;
    this.container.x = -rect.x * sx + (window.innerWidth - sx * rect.width) / 2;
    this.container.y =
      -rect.y * sy + (window.innerHeight - sy * rect.height) / 2;
    this.stage.update();
  }

  fit() {
    const rect = this.getBoundary();
    const sx = window.innerWidth / rect.width;
    const sy = window.innerHeight / rect.height;
    const sc = Math.min(sx, sy);
    this.wrapper.x = 0;
    this.wrapper.y = 0;
    this.container.scaleX = sc;
    this.container.scaleY = sc;
    this.container.x = -rect.x * sc + (window.innerWidth - sc * rect.width) / 2;
    this.container.y =
      -rect.y * sc + (window.innerHeight - sc * rect.height) / 2;
    this.stage.update();
  }

  fill() {
    const rect = this.getBoundary();
    const sx = window.innerWidth / rect.width;
    const sy = window.innerHeight / rect.height;
    const sc = Math.max(sx, sy);
    this.wrapper.x = 0;
    this.wrapper.y = 0;
    this.container.scaleX = sc;
    this.container.scaleY = sc;
    this.container.x = -rect.x * sc + (window.innerWidth - sc * rect.width) / 2;
    this.container.y =
      -rect.y * sc + (window.innerHeight - sc * rect.height) / 2;
    this.stage.update();
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

  invalidate() {
    this.stage.invalidate();
  }
}
