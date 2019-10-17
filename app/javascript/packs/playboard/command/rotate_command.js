import { Matrix2D } from "@createjs/easeljs";

import TransformCommand from "./transform_command";

export default class RotateCommand extends TransformCommand {
  constructor(piece, center, degree) {
    super();
    Object.assign(this, { piece, center, degree });
    const mtx = new Matrix2D()
      .translate(center.x, center.y)
      .rotate(degree)
      .translate(-center.x, -center.y);
    this.position = piece.position().apply(mtx);
    this.rotation = piece.rotation() + degree;
  }

  squash(cmd) {
    if (
      cmd instanceof RotateCommand &&
      cmd.piece === this.piece &&
      cmd.center === this.center
    ) {
      this.degree += cmd.degree;
      const { position, rotation } = cmd;
      Object.assign(this, { position, rotation });
      return true;
    }

    return false;
  }

  isValid() {
    return this.piece && this.piece.isAlive() && this.center;
  }
}
