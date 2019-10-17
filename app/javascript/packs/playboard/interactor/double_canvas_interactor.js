import { Stage, Point, Shadow } from "@createjs/easeljs";

import Command from "../command/command";
import TransformCommand from "../command/transform_command";
import TranslateCommand from "../command/translate_command";
import RotateCommand from "../command/rotate_command";
import MergeCommand from "../command/merge_command";

export default class DoubleCanvasInteractor {
  constructor(puzzle) {
    this.puzzle = puzzle;
    this.colors = {
      shadow: "#AFF"
    };
  }

  attach() {
    {
      const canvas_ = document.createElement("canvas");
      canvas_.id = "active";
      $(this.puzzle.stage.canvas).after(canvas_);

      $("#field").css("background-color", "rgba(200, 255, 105, 0.5)");
      $(canvas_)
        .css("position", "absolute")
        .css("background-color", "rgba(200, 255, 255, 0.5)")
        .hide();

      this.active_stage = new Stage(canvas_);
    }

    $(this.puzzle.stage.canvas).on("mousewheel", e => {
      e.preventDefault();
      const e_ = e.originalEvent;
      if (!this.captured) {
        const obj = this.puzzle.stage.getObjectUnderPoint(
          e_.clientX,
          e_.clientY
        );
        const p = obj && obj.piece.getEntity();
        if (p)
          this.capture(
            p,
            this.puzzle.container.globalToLocal(e_.clientX, e_.clientY)
          );
      }
      if (!this.captured) {
        if (e_.wheelDelta > 0) this.zoom(e_.x, e_.y, 1.2);
        else this.zoom(e_.x, e_.y, 1 / 1.2);
      }
    });

    $(this.puzzle.stage.canvas).on("mousedown", e => {
      e.preventDefault();
      const pt = new Point(e.offsetX, e.offsetY);
      const obj = this.puzzle.stage.getObjectUnderPoint(pt.x, pt.y);
      const p = obj && obj.piece.getEntity();
      if (p) this.capture(p, pt.to(this.puzzle.container), e);
      else this.dragStage(e);
    });

    Command.onPost.push(cmd => {
      const capturedPiece = this.captured && this.captured.piece;
      if (cmd instanceof TransformCommand) {
        if (capturedPiece === cmd.piece) {
          if (cmd instanceof RotateCommand) {
            this.putToActiveLayer(cmd.piece);
          } else if (cmd instanceof TranslateCommand) {
            const { canvas } = cmd.piece.shape.stage;
            const pt0 = $(canvas).offset();
            $(canvas).offset({
              left: pt0.left + cmd.vector.x * this.puzzle.container.scaleX,
              top: pt0.top + cmd.vector.y * this.puzzle.container.scaleY
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
        if (capturedPiece === cmd.piece || capturedPiece === cmd.mergee) {
          this.release();
        }
        this.puzzle.invalidate();
      }
    });
  }

  putToActiveLayer(p) {
    {
      const { x, y, width, height } = p.getBoundary().inflate(10);
      const pt0 = this.puzzle.container.localToWindow(x, y);
      const pt1 = this.puzzle.container.localToWindow(x + width, y + height);
      this.active_stage.copyTransform(this.puzzle.container);
      this.active_stage.x = 0;
      this.active_stage.y = 0;
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
      this.updateActive();
    }
  }

  updateActive() {
    if (this.active_stage.children.length > 0) {
      $(this.active_stage.canvas).show();
    } else {
      $(this.active_stage.canvas).hide();
    }
    this.active_stage.update();
  }

  capture(p, point, event) {
    if (!p.isAlive()) return;

    if (this.captured) Command.commit();
    else {
      window.console.log(`captured[${p.id}] ( ${point.x}, ${point.y} )`);
      this.captured = {
        piece: p,
        point,
        dragging: !!event
      };

      const blur = 8;
      p.shape.shadow = new Shadow(this.colors.shadow, 0, 0, blur);
      this.putToActiveLayer(p);
      this.puzzle.invalidate();

      $(this.active_stage.canvas).on({
        mousedown: e => {
          e.preventDefault();
          this.captured.dragging = true;
          this.captured.point = new Point(e.clientX, e.clientY)
            .fromWindow()
            .to(this.puzzle.container);
          $("body").css("cursor", "move");
        },
        mouseup: e => {
          e.preventDefault();
          if (this.captured) {
            this.captured.dragging = false;
            const p_ = this.captured.piece.findMergeableOn(point);
            if (p_) new MergeCommand(p_, this.captured.piece).commit();
          }
          $("body").css("cursor", "auto");
        },
        mousewheel: e => {
          e.preventDefault();
          const e_ = e.originalEvent;
          if (this.captured) {
            const { piece, point: point_ } = this.captured;
            new RotateCommand(piece, point_, e_.wheelDelta / 10).post();
          }
        }
      });
      $(window).on({
        mousemove: e => {
          if (this.captured && this.captured.dragging) {
            const pt = new Point(e.clientX, e.clientY)
              .fromWindow()
              .to(this.puzzle.container);
            const vec = pt.subtract(this.captured.point);
            this.captured.point = pt;
            new TranslateCommand(this.captured.piece, vec).post();
          } else {
            this.captured.point = new Point(e.clientX, e.clientY)
              .fromWindow()
              .to(this.puzzle.container);
            const pt = this.captured.point.to(this.captured.piece.shape);
            if (!this.captured.piece.shape.hitTest(pt.x, pt.y)) this.release();
          }
        }
      });
      if (event && event.type === "mousedown")
        $(this.active_stage.canvas).trigger(event);
    }
  }

  release() {
    if (this.captured) {
      window.console.log(`released[${this.captured.piece.id}]`);
      const p = this.captured.piece;
      p.shape.shadow = null;
      if (p.isAlive()) {
        const { x, y } = p.position();
        Object.assign(p.shape, { x, y, rotation: p.rotation() });
        this.puzzle.container.addChild(p.shape);
      }
      this.captured = null;
      $(this.active_stage.canvas).off("mousedown mouseup mousewheel");
      $(window).off("mousemove");
      Command.commit();
      this.puzzle.stage.update();
      this.updateActive();
    }
  }

  zoom(x, y, scale) {
    this.puzzle.zoom(x, y, scale);
  }

  dragStage(event) {
    const { width, height } = window.screen;
    const pt0 = new Point(-width / 2, -height / 2)
      .fromWindow()
      .to(this.puzzle.wrapper);
    const pt1 = new Point((width * 3) / 2, (height * 3) / 2)
      .fromWindow()
      .to(this.puzzle.wrapper);
    this.puzzle.wrapper.cache(pt0.x, pt0.y, pt1.x - pt0.x, pt1.y - pt0.y);
    let lastPoint = new Point(event.clientX, event.clientY);
    $(window).on({
      mousemove: e => {
        e.preventDefault();
        const pt = new Point(e.clientX, e.clientY);
        this.puzzle.wrapper.x += pt.x - lastPoint.x;
        this.puzzle.wrapper.y += pt.y - lastPoint.y;

        lastPoint = pt;
        this.puzzle.invalidate();
        $("body").css("cursor", "move");
      },
      mouseup: e => {
        e.preventDefault();
        this.puzzle.wrapper.uncache();
        this.puzzle.invalidate();
        $(window).off("mousemove mouseup");
        $("body").css("cursor", "auto");
      }
    });
  }
}
