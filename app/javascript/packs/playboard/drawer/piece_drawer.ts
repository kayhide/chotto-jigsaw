import { Point, Graphics, Shape } from "@createjs/easeljs";

import Piece from "../model/piece";

export default class PieceDrawer {
  drawsImage = true;
  drawsStroke = false;
  drawsControlLine = false;
  drawsBoundary = false;
  drawsCenter = false;

  puzzle = null;

  get image(): ImageData {
    return this.puzzle.image;
  }

  constructor(opts = {}) {
    Object.assign(this, opts);
  }

  draw(piece: Piece, g: Graphics): void {
    g.clear();
    if (this.drawsImage) {
      g.beginBitmapFill(this.image);
    } else {
      g.beginFill("#9fa");
    }
    if (this.drawsStroke) {
      g.setStrokeStyle(2).beginStroke("#f0f");
    }
    piece.loops.forEach(pts => this.drawCurve(pts, g));
    g.endFill().endStroke();

    if (this.drawsBoundary) {
      const { x, y, width, height } = piece.localBoundary;
      g.setStrokeStyle(2)
        .beginStroke("#0f0")
        .rect(x, y, width, height);
    }
    if (this.drawsControlLine) {
      g.setStrokeStyle(2).beginStroke("#fff");
      piece.loops.forEach(pts => this.drawPolyline(pts, g));
    }
    if (this.drawsCenter) {
      const { x, y } = piece.localBoundary.center;
      g.setStrokeStyle(2)
        .beginFill("#390")
        .drawCircle(x, y, this.puzzle.linearMeasure / 32);
    }
  }

  drawHitArea(piece: Piece, g: Graphics): void {
    const { x, y, width, height } = piece.localBoundary;
    g.beginFill("#000").drawRect(x, y, width, height);
  }

  drawCurve(points: Array<Point>, g: Graphics): void {
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
          g.lineTo(pts[2].x, pts[2].y);
        }
      });
  }

  drawPolyline(points: Array<Point>, g: Graphics): void {
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
