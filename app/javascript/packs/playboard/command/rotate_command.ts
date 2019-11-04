import { Point, Matrix2D } from "@createjs/easeljs";

import Piece from "../model/piece";
import Command from "./command";
import TransformCommand from "./transform_command";
import * as Point_ from "../../easeljs-ext/Point.bs";

export default class RotateCommand extends TransformCommand {
  center: Point;
  degree: number;

  constructor(piece: Piece, center: Point, degree: number) {
    super();
    Object.assign(this, { piece, center, degree });
    const mtx = new Matrix2D()
      .translate(center.x, center.y)
      .rotate(degree)
      .translate(-center.x, -center.y);
    this.position = Point_.apply(mtx, piece.position);
    this.rotation = piece.rotation + degree;
  }

  squash(cmd: Command): Command | null {
    if (
      cmd instanceof RotateCommand &&
      cmd.piece === this.piece &&
      cmd.center.x === this.center.x &&
      cmd.center.y === this.center.y
    ) {
      this.degree += cmd.degree;
      const { position, rotation } = cmd;
      Object.assign(this, { position, rotation });
      return this;
    }

    return null;
  }

  isValid(): boolean {
    return this.piece && this.piece.isAlive() && this.center;
  }
}
