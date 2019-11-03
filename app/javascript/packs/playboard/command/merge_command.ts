import Logger from "../../common/logger";
import Piece from "../model/piece";
import Command from "./command";

export default class MergeCommand extends Command {
  mergee: Piece;

  constructor(piece, mergee) {
    super();
    this.piece = piece.entity;
    this.mergee = mergee.entity;
  }

  execute(): void {
    const ids = [];
    this.piece.getAdjacentPieces().forEach(p => {
      if (p.id !== this.mergee.id && !ids.includes(p.id)) {
        ids.push(p.id);
      }
    });
    this.mergee.getAdjacentPieces().forEach(p => {
      if (p.id !== this.piece.id && !ids.includes(p.id)) {
        ids.push(p.id);
      }
    });
    this.piece.neighborIds = ids;
    this.mergee.merger = this.piece;

    this.mergee.loops.forEach(lp => this.piece.addLoop(lp));
    this.piece.enbox(this.mergee);
  }

  isValid(): boolean {
    return this.mergee && this.mergee.isAlive() && this.piece !== this.mergee;
  }
}
