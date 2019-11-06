import { Point, Rectangle } from "@createjs/easeljs";

import Puzzle from "./model/puzzle";
import * as Rectangle_ from "../easeljs-ext/Rectangle.bs";

export default class View {
  static fit(puzzle: Puzzle): void {
    this.contain(puzzle, puzzle.boundary);
  }

  static contain(
    puzzle: Puzzle,
    rect: Rectangle,
    margin = puzzle.linearMeasure
  ): void {
    const { innerWidth: width, innerHeight: height } = window;
    const rect_ = Rectangle_.inflate(margin, rect);
    const sc = Math.min(width / rect_.width, height / rect_.height);
    puzzle.container.x = -rect_.x * sc + (width - sc * rect_.width) / 2;
    puzzle.container.y = -rect_.y * sc + (height - sc * rect_.height) / 2;
    puzzle.container.scaleX = sc;
    puzzle.container.scaleY = sc;
    puzzle.invalidate();
  }
}
