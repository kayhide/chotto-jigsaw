import Command from "./command";

export default class TransformCommand extends Command {
  execute() {
    this.piece.position(this.position).rotation(this.rotation);
  }
}
