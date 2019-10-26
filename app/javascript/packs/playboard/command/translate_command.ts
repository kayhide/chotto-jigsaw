import { Point } from "@createjs/easeljs";

import Piece from "../model/piece";
import Command from "./command";
import TransformCommand from "./transform_command";

export default class TranslateCommand extends TransformCommand {
  piece: Piece;
  vector: Point;

  constructor(piece: Piece, vector: Point) {
    super();
    Object.assign(this, { piece, vector });
    this.position = piece.position.add(vector);
    this.rotation = piece.rotation;
  }

  squash(cmd: Command): boolean {
    if (cmd instanceof TranslateCommand && cmd.piece === this.piece) {
      this.vector = this.vector.add(cmd.vector);
      const { position, rotation } = cmd;
      Object.assign(this, { position, rotation });
      return true;
    }

    return false;
  }

  isValid(): boolean {
    return this.piece && this.piece.isAlive();
  }
}
