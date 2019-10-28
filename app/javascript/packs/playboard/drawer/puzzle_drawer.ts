import { Point, Shape, Graphics } from "@createjs/easeljs";

import Puzzle from "../model/puzzle";
import Piece from "../model/piece";
import PieceDrawer from "./piece_drawer";

export default class PuzzleDrawer {
  drawsGuide = false;

  constructor(opts = {}) {
    Object.assign(this, opts);
  }

  draw(puzzle: Puzzle, g: Graphics): void {
    g.clear();
    if (this.drawsGuide) this.drawGuide(g);

    const drawer = new PieceDrawer();
    drawer.puzzle = puzzle;

    puzzle.pieces.forEach(p => {
      drawer.draw(p, p.shape.graphics);
      p.cache(this.cacheScale(puzzle));
      const shape = new Shape();
      drawer.drawHitArea(p, shape.graphics);
      p.shape.hitArea = shape;
    });
  }

  drawGuide(g: Graphics): void {
    g.setStrokeStyle(1)
      .beginStroke("rgba(127,255,255,0.7)")
      .beginFill("rgba(127,255,255,0.5)")
      .drawCircle(0, 0, 5);

    g.setStrokeStyle(1).beginStroke("rgba(127,255,255,0.7)");
    for (let i = -5; i < 6; i += 1) {
      g.moveTo(-500, i * 100)
        .lineTo(500, i * 100)
        .moveTo(i * 100, -500)
        .lineTo(i * 100, 500);
    }
  }

  cacheScale(puzzle: Puzzle): number {
    return Math.min(Math.max(180 / puzzle.linearMeasure, 1), 4);
  }
}
