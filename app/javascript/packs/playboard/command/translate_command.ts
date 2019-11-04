import { Point } from "@createjs/easeljs";

import Piece from "../model/piece";
import Command from "./command";
import TransformCommand from "./transform_command";
import * as Point_ from "../../easeljs-ext/Point.bs";

export default class TranslateCommand extends TransformCommand {
  piece: Piece;
  vector: Point;

  constructor(piece: Piece, vector: Point) {
    super();
    Object.assign(this, { piece, vector });
    this.position = Point_.add(piece.position, vector);
    this.rotation = piece.rotation;
  }

  squash(cmd: Command): Command | null {
    if (cmd instanceof TranslateCommand && cmd.piece === this.piece) {
      this.vector = Point_.add(this.vector, cmd.vector);
      const { position, rotation } = cmd;
      Object.assign(this, { position, rotation });
      return this;
    }

    return null;
  }

  isValid(): boolean {
    return this.piece && this.piece.isAlive();
  }
}
