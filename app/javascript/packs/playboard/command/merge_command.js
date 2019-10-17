import Command from "./command";

export default class MergeCommand extends Command {
  constructor(piece, mergee) {
    super();
    this.piece = piece.getEntity();
    this.mergee = mergee;
  }

  execute() {
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
    this.piece.neighbor_ids = ids;
    this.mergee.merger = this.piece;

    this.mergee.loops.forEach(lp => this.piece.addLoop(lp));
    this.piece.enbox(this.mergee);
  }

  isValid() {
    return this.mergee && this.mergee.isAlive() && this.piece !== this.mergee;
  }
}
