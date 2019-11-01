import { Point } from "@createjs/easeljs";

import Piece from "./model/piece";
import Command from "./command/command";
import MergeCommand from "./command/merge_command";
import TranslateCommand from "./command/translate_command";
import RotateCommand from "./command/rotate_command";

export default class Bridge {
  static decode(src: any): Command {
    if (src.type === "MergeCommand") {
      return new MergeCommand(
        Piece.find(src.piece_id),
        Piece.find(src.mergee_id)
      );
    } else if (src.type === "TranslateCommand") {
      return new TranslateCommand(
        Piece.find(src.piece_id),
        new Point(src.delta_x, src.delta_y)
      );
    } else if (src.type === "RotateCommand") {
      return new RotateCommand(
        Piece.find(src.piece_id),
        new Point(src.pivot_x, src.pivot_y),
        src.delta_degree
      );
    }
    return null;
  }
}
