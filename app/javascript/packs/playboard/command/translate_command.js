import TransformCommand from "./transform_command";

export default class TranslateCommand extends TransformCommand {
  constructor(piece, vector) {
    super();
    Object.assign(this, { piece, vector });
    this.position = piece.position().add(vector);
    this.rotation = piece.rotation();
  }

  squash(cmd) {
    if (cmd instanceof TranslateCommand && cmd.piece === this.piece) {
      this.vector = this.vector.add(cmd.vector);
      const { position, rotation } = cmd;
      Object.assign(this, { position, rotation });
      return true;
    }

    return false;
  }

  isValid() {
    return this.piece && this.piece.isAlive();
  }
}
