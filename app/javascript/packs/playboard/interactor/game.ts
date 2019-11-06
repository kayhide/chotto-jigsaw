import { Ticker, Point, Container, Stage } from "@createjs/easeljs";

import Logger from "../../common/logger";
import Puzzle from "../model/puzzle";
import Piece from "../model/piece";
import Command from "../command/command";
import TransformCommand from "../command/transform_command";
import TranslateCommand from "../command/translate_command";
import RotateCommand from "../command/rotate_command";
import MergeCommand from "../command/merge_command";
import * as Point_ from "../../easeljs-ext/Point.bs";
import * as Rectangle_ from "../../easeljs-ext/Rectangle.bs";

export interface Dragger {
  active: boolean;
  piece: Piece;
  move: (Point) => void;
  spin: (number) => void;
  resetSpin: (number) => void;
  attempt: () => Dragger;
  end: () => Dragger;
  continue: (Point) => Dragger;
}

export type Scaler = (Point, number) => void;
export type Mover = (Point) => void;

export default class Game {
  puzzle: Puzzle;

  private activeStage: Container;

  get canvas(): HTMLCanvasElement {
    return this.puzzle.stage.canvas;
  }

  get defaultDragger(): Dragger {
    const dragger: Dragger = {
      active: false,
      piece: null,
      move: (_pt: Point) => {},
      spin: (_deg: number) => {},
      resetSpin: (_deb: number) => {},
      attempt: () => this.defaultDragger,
      end: () => this.defaultDragger,
      continue: pt => this.dragStart(pt)
    };
    return dragger;
  }

  constructor(puzzle) {
    this.puzzle = puzzle;

    {
      const canvas_ = $("#active-canvas").get(0);
      this.activeStage = new Stage(canvas_);
    }

    const throttleRotate = _.throttle(cmd => {
      this.putToActiveLayer(cmd.piece);
    }, 100);
    Command.onPost(cmd => {
      if (cmd instanceof TransformCommand) {
        if (this.isCaptured(cmd.piece)) {
          if (cmd instanceof RotateCommand) {
            throttleRotate(cmd);
          } else if (cmd instanceof TranslateCommand) {
            this.handleTranslate(cmd);
          }
        }
      }
    });
    Command.onCommit(cmds => {
      cmds.forEach(cmd => {
        if (cmd instanceof TransformCommand) {
          if (cmd.piece.isAlive()) {
            const {
              piece,
              position: { x, y },
              rotation
            } = cmd;
            Object.assign(piece.shape, { x, y, rotation });
          }
        } else if (cmd instanceof MergeCommand) {
          if (this.isCaptured(cmd.piece)) {
            this.release(cmd.piece);
          }
          if (this.isCaptured(cmd.mergee)) {
            this.release(cmd.mergee);
          }
        }
        this.puzzle.invalidate();
      });
    });

    Ticker.framerate = 60;
    Ticker.addEventListener("tick", () => {
      if (puzzle.stage.invalidated) {
        puzzle.stage.update();
        puzzle.stage.invalidated = false;
      }
    });
  }

  handleTranslate(cmd: TranslateCommand): void {
    const { canvas } = this.activeStage;
    const { left, top } = $(canvas).offset();
    $(canvas).offset({
      left: left + cmd.vector.x * this.puzzle.container.scaleX,
      top: top + cmd.vector.y * this.puzzle.container.scaleY
    });
  }

  getScaler(): Scaler {
    const sc0 = this.puzzle.currentScale;
    return ({ x, y }, delta): void => {
      this.puzzle.scale(x, y, delta * sc0);
    };
  }

  getMover({ x, y }: Point): Mover {
    const pt0 = new Point(
      x - this.puzzle.container.x,
      y - this.puzzle.container.y
    );
    return ({ x: x_, y: y_ }): void => {
      Object.assign(this.puzzle.container, { x: x_ - pt0.x, y: y_ - pt0.y });
      this.puzzle.invalidate();
    };
  }

  dragStart({ x, y }: Point): Dragger {
    const obj = this.puzzle.stage.getObjectUnderPoint(x, y);
    const piece = obj && obj.piece && obj.piece.entity;
    if (piece) {
      let pt0 = Point_.to_(this.puzzle.container, new Point(x, y));
      let deg0 = 0;
      this.capture(piece, pt0);
      const dragger: Dragger = {
        active: true,
        piece,
        move: ({ x: x_, y: y_ }) => {
          const pt1 = Point_.to_(this.puzzle.container, new Point(x_, y_));
          const vec = Point_.subtract(pt0, pt1);
          new TranslateCommand(piece, vec).post();
          pt0 = pt1;
        },
        spin: deg => {
          new RotateCommand(piece, pt0, deg - deg0).post();
          deg0 = deg;
        },
        resetSpin: deg => {
          deg0 = deg;
        },
        attempt: () => {
          const p_ = this.findMergeableOn(piece, pt0);
          if (p_) {
            this.release(piece);
            new MergeCommand(p_, piece).commit();
            return this.defaultDragger;
          }
          return dragger;
        },
        end: () => {
          this.release(piece);

          const p_ = this.findMergeableOn(piece, pt0);
          if (p_) new MergeCommand(p_, piece).commit();

          return this.defaultDragger;
        },
        continue: ({ x: x_, y: y_ }) => {
          const canvas_ = $(this.activeStage.canvas);
          const pt = Point_.to_(
            this.activeStage,
            Point_.from_(
              this.puzzle.container,
              Point_.to_(this.puzzle.container, new Point(x_, y_))
            )
          );
          const obj_ = this.activeStage.getObjectUnderPoint(pt.x, pt.y);
          const piece_ = obj_ && obj_.piece.entity;
          if (piece_ === piece) {
            pt0 = Point_.to_(this.puzzle.container, new Point(x_, y_));
            return dragger;
          }
          dragger.end();
          return this.dragStart({ x: x_, y: y_ });
        }
      };
      return dragger;
    }
    return this.defaultDragger;
  }

  putToActiveLayer(p: Piece): void {
    {
      const mtx = p.matrix;
      const pts = Rectangle_.cornerPoints(p.localBoundary).map(pt =>
        Point_.apply(mtx, pt)
      );
      const { x, y, width, height } = Rectangle_.fromPoints(pts);
      const pt0 = Point_.add(
        this.puzzle.container.localToWindow(x, y),
        new Point(-10, -10)
      );
      const pt1 = Point_.add(
        this.puzzle.container.localToWindow(x + width, y + height),
        new Point(10, 20)
      );
      this.activeStage.copyTransform(this.puzzle.container);
      this.activeStage.canvas.width = pt1.x - pt0.x;
      this.activeStage.canvas.height = pt1.y - pt0.y;
      $(this.activeStage.canvas)
        .css("left", pt0.x)
        .css("top", pt0.y)
        .show();
    }
    {
      const { x, y } = Point_.to_(
        this.activeStage,
        Point_.from_(this.puzzle.container, p.position)
      );
      Object.assign(p.shape, { x, y, rotation: p.rotation });
      this.activeStage.addChild(p.shape);
    }

    this.activeStage.update();
    $(this.activeStage.canvas).show();
  }

  clearActiveLayer(): void {
    while (this.activeStage.numChildren > 0) {
      const p = this.activeStage.getChildAt(0).piece;
      const { x, y } = p.position;
      Object.assign(p.shape, { x, y, rotation: p.rotation });
      this.puzzle.container.addChild(p.shape);
    }
    $(this.activeStage.canvas).hide();
  }

  isCaptured(p: Piece): boolean {
    return p.shape.parent === this.activeStage;
  }

  capture(p: Piece, point: Point): void {
    if (!p.isAlive()) return;

    Logger.trace(`captured[${p.id}] ( ${point.x}, ${point.y} )`);
    this.putToActiveLayer(p);
    this.puzzle.invalidate();
  }

  release(p: Piece): void {
    Logger.trace(`released[${p.id}]`);
    Command.commit();

    this.clearActiveLayer();
    this.puzzle.invalidate();
  }

  findMergeableOn(p: Piece, point: Point): Piece {
    return p
      .getAdjacentPieces()
      .find(p1 => this.isWithinTolerance(p, p1, point));
  }

  isWithinTolerance(source: Piece, target: Piece, pt: Point): boolean {
    if (
      Math.abs(this.getDegreeBetween(source, target)) <
      this.puzzle.rotationTolerance
    ) {
      const pt0 = Point_.apply(source.matrix.invert(), pt);
      const pt1 = Point_.apply(target.matrix.invert(), pt);
      if (Point_.distanceTo(pt1, pt0) < this.puzzle.translationTolerance) {
        return true;
      }
    }
    return false;
  }

  getDegreeBetween(source: Piece, target: Piece): number {
    const deg = (target.rotation - source.rotation) % 360;
    if (deg > 180) {
      return deg - 360;
    }
    if (deg <= -180) {
      return deg + 360;
    }
    return deg;
  }
}
