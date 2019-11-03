import { Point } from "@createjs/easeljs";

import Logger from "../common/logger";
import Piece from "./model/piece";
import Command from "./command/command";
import MergeCommand from "./command/merge_command";
import TranslateCommand from "./command/translate_command";
import RotateCommand from "./command/rotate_command";

export default class Bridge {
  static encode(cmd: Command): any {
    if (cmd instanceof TranslateCommand) {
      const {
        piece: { id: piece_id },
        position: { x: position_x, y: position_y },
        rotation,
        vector: { x: delta_x, y: delta_y }
      } = cmd;
      return {
        type: "TranslateCommand",
        piece_id,
        position_x,
        position_y,
        rotation,
        delta_x,
        delta_y
      };
    } else if (cmd instanceof RotateCommand) {
      const {
        piece: { id: piece_id },
        position: { x: position_x, y: position_y },
        rotation,
        center: { x: pivot_x, pivot_y },
        degree: delta_degree
      } = cmd;
      return {
        type: "RotateCommand",
        piece_id,
        position_x,
        position_y,
        rotation,
        pivot_x,
        pivot_y,
        delta_degree
      };
    } else if (cmd instanceof MergeCommand) {
      const {
        piece: { id: piece_id },
        mergee: { id: mergee_id }
      } = cmd;
      return {
        type: "MergeCommand",
        piece_id,
        mergee_id
      };
    }
  }

  static decode(src: any): Command {
    if (src.type === "TranslateCommand") {
      const { position_x, position_y, rotation } = src;
      return Object.assign(
        new TranslateCommand(
          Piece.find(src.piece_id),
          new Point(src.delta_x, src.delta_y)
        ),
        { position: new Point(position_x, position_y), rotation }
      );
    } else if (src.type === "RotateCommand") {
      const { position_x, position_y, rotation } = src;
      return Object.assign(
        new RotateCommand(
          Piece.find(src.piece_id),
          new Point(src.pivot_x, src.pivot_y),
          src.delta_degree
        ),
        { position: new Point(position_x, position_y), rotation }
      );
    } else if (src.type === "MergeCommand") {
      return new MergeCommand(
        Piece.find(src.piece_id),
        Piece.find(src.mergee_id)
      );
    }
    return null;
  }
}
