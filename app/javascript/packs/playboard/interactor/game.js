import { Stage, Point, Shadow } from "@createjs/easeljs";

import Logger from "../logger";
import Command from "../command/command";
import TransformCommand from "../command/transform_command";
import TranslateCommand from "../command/translate_command";
import RotateCommand from "../command/rotate_command";
import MergeCommand from "../command/merge_command";

export default class Game {
  _guide = false;

  get canvas() {
    return this.puzzle.stage.canvas;
  }

  get guide() {
    return this._guide;
  }

  set guide(f) {
    this._guide = f;
    this.puzzle.toggleGuide();
    if (this._guide) {
      $(this.active_stage.canvas).addClass("z-depth-3");
    } else {
      $(this.active_stage.canvas).removeClass("z-depth-3");
    }
  }

  get defaultDragger() {
    return {
      active: false,
      piece: null,
      move: () => {},
      spin: () => {},
      resetSpin: () => {},
      attempt: () => this.defaultDragger,
      end: () => this.defaultDragger,
      continue: pt => this.dragStart(pt)
    };
  }

  constructor(puzzle) {
    this.puzzle = puzzle;
    this.colors = {
      shadow: "#fff"
    };

    {
      const canvas_ = document.createElement("canvas");
      canvas_.id = "active";

      $(canvas_)
        .addClass("no-interaction")
        .css("position", "absolute")
        .css("filter", "drop-shadow(0 8px 6px rgba(0, 0, 0, 0.40)")
        .hide();

      this.active_stage = new Stage(canvas_);
      const blur = 2;
      const shadow = new Shadow(this.colors.shadow, 0, 0, blur);
      Object.assign(this.active_stage, { shadow });
      $(this.puzzle.stage.canvas).after(canvas_);
    }

    Command.onPost.push(cmd => {
      if (cmd instanceof TransformCommand) {
        if (this.isCaptured(cmd.piece)) {
          if (cmd instanceof RotateCommand) {
            this.putToActiveLayer(cmd.piece);
          } else if (cmd instanceof TranslateCommand) {
            const { canvas } = this.active_stage;
            const { left, top } = $(canvas).offset();
            $(canvas).offset({
              left: left + cmd.vector.x * this.puzzle.container.scaleX,
              top: top + cmd.vector.y * this.puzzle.container.scaleY
            });
          }
        } else {
          const p = cmd.piece;
          const { x, y } = p.position();
          Object.assign(p.shape, { x, y, rotation: p.rotation() });
          this.puzzle.invalidate();
        }
      }
      if (cmd instanceof MergeCommand) {
        if (this.isCaptured(cmd.piece)) {
          this.release(cmd.piece);
        }
        if (this.isCaptured(cmd.mergee)) {
          this.release(cmd.mergee);
        }
      }
    });
  }

  getScaler() {
    const sc0 = this.puzzle.currentScale;
    return ({ x, y }, delta) => {
      this.puzzle.scale(x, y, delta * sc0);
    };
  }

  getMover({ x, y }) {
    const pt0 = new Point(x - this.puzzle.wrapper.x, y - this.puzzle.wrapper.y);
    return ({ x: x_, y: y_ }) => {
      Object.assign(this.puzzle.wrapper, { x: x_ - pt0.x, y: y_ - pt0.y });
      this.puzzle.invalidate();
    };
  }

  dragStart({ x, y }) {
    const obj = this.puzzle.stage.getObjectUnderPoint(x, y);
    const piece = obj && obj.piece.getEntity();
    if (piece) {
      let pt0 = new Point(x, y).to(this.puzzle.container);
      let deg0 = 0;
      this.capture(piece, pt0);
      const dragger = {
        active: true,
        piece,
        move: ({ x: x_, y: y_ }) => {
          const pt1 = new Point(x_, y_).to(this.puzzle.container);
          const vec = pt1.subtract(pt0);
          new TranslateCommand(piece, vec).post();
          pt0 = pt1;
        },
        spin: deg => {
          new RotateCommand(piece, pt0, deg - deg0).post();
          deg0 = deg;
        },
        resetSpin: () => {
          deg0 = 0;
        },
        attempt: () => {
          const p_ = piece.findMergeableOn(pt0);
          if (p_) {
            this.release(piece);
            new MergeCommand(p_, piece).commit();
            return this.defaultDragger;
          }
          return dragger;
        },
        end: () => {
          this.release(piece);

          const p_ = piece.findMergeableOn(pt0);
          if (p_) new MergeCommand(p_, piece).commit();

          return this.defaultDragger;
        },
        continue: ({ x: x_, y: y_ }) => {
          const canvas_ = $(this.active_stage.canvas);
          const pt = new Point(
            x_ - canvas_.position().left,
            y_ - canvas_.position().top
          ).to(this.active_stage);
          const obj_ = this.active_stage.getObjectUnderPoint(pt.x, pt.y);
          const piece_ = obj_ && obj_.piece.getEntity();
          if (piece_ === piece) {
            pt0 = new Point(x_, y_).to(this.puzzle.container);
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

  putToActiveLayer(p) {
    {
      const { x, y, width, height } = p.getBoundary();
      const pt0 = this.puzzle.container
        .localToWindow(x, y)
        .add(new Point(-10, -10));
      const pt1 = this.puzzle.container
        .localToWindow(x + width, y + height)
        .add(new Point(10, 10));
      this.active_stage.copyTransform(this.puzzle.container);
      this.active_stage.canvas.width = pt1.x - pt0.x;
      this.active_stage.canvas.height = pt1.y - pt0.y;
      $(this.active_stage.canvas)
        .css("left", pt0.x)
        .css("top", pt0.y)
        .show();
    }

    {
      const { x, y } = p
        .position()
        .from(this.puzzle.container)
        .to(this.active_stage);
      Object.assign(p.shape, { x, y, rotation: p.rotation() });
      this.active_stage.addChild(p.shape);
    }

    this.active_stage.update();
    $(this.active_stage.canvas).show();
  }

  clearActiveLayer() {
    while (this.active_stage.numChildren > 0) {
      const p = this.active_stage.getChildAt(0).piece;
      const { x, y } = p.position();
      Object.assign(p.shape, { x, y, rotation: p.rotation(), shadow: null });
      this.puzzle.container.addChild(p.shape);
    }
    $(this.active_stage.canvas).hide();
  }

  isCaptured(p) {
    return p.shape.parent === this.active_stage;
  }

  capture(p, point) {
    if (!p.isAlive()) return;

    Logger.trace(`captured[${p.id}] ( ${point.x}, ${point.y} )`);
    this.putToActiveLayer(p);
    this.puzzle.invalidate();
  }

  release(p) {
    Logger.trace(`released[${p.id}]`);
    Command.commit();

    this.clearActiveLayer();
    this.puzzle.invalidate();
  }

  centerize() {
    const width = window.innerWidth;
    const height = window.innerHeight;
    const rect = this.puzzle.getBoundary();
    const { scaleX: sx, scaleY: sy } = this.puzzle.container;
    this.puzzle.container.x = -rect.x * sx + (width - sx * rect.width) / 2;
    this.puzzle.container.y = -rect.y * sy + (height - sy * rect.height) / 2;
    this.puzzle.stage.update();
  }

  fit() {
    const width = window.innerWidth;
    const height = window.innerHeight;
    const rect = this.puzzle.getBoundary();
    const sx = width / rect.width;
    const sy = height / rect.height;
    const sc = Math.min(sx, sy);
    this.puzzle.wrapper.x = 0;
    this.puzzle.wrapper.y = 0;
    this.puzzle.container.x = -rect.x * sc + (width - sc * rect.width) / 2;
    this.puzzle.container.y = -rect.y * sc + (height - sc * rect.height) / 2;
    this.puzzle.container.scaleX = sc;
    this.puzzle.container.scaleY = sc;
    this.puzzle.stage.update();
  }

  fill() {
    const width = window.innerWidth;
    const height = window.innerHeight;
    const rect = this.puzzle.getBoundary();
    const sx = width / rect.width;
    const sy = height / rect.height;
    const sc = Math.max(sx, sy);
    this.puzzle.wrapper.x = 0;
    this.puzzle.wrapper.y = 0;
    this.puzzle.container.x = -rect.x * sc + (width - sc * rect.width) / 2;
    this.puzzle.container.y = -rect.y * sc + (height - sc * rect.height) / 2;
    this.puzzle.container.scaleX = sc;
    this.puzzle.container.scaleY = sc;
    this.puzzle.stage.update();
  }
}
