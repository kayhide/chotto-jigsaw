import { Point } from "@createjs/easeljs";

import Command from "./command";

export default class TransformCommand extends Command {
  position: Point;
  rotation: number;

  execute(): void {
    const { position, rotation } = this;
    Object.assign(this.piece, { position, rotation });
  }
}
