import * as Logger from "../../common/Logger.bs";
import Game from "./game";

export default class BrowserInteractor {
  game: Game;

  constructor(game) {
    this.game = game;
  }

  attach(): void {
    $(window).on("resize", this.onWindowResize.bind(this));
    this.onWindowResize();
  }

  onWindowResize(): void {
    const { innerWidth: width, innerHeight: height } = window;
    Logger.trace(`window resized: width: ${width}, height: ${height}`);

    Object.assign(this.game.canvas, { width, height });
    $(this.game.canvas)
      .css("left", 0)
      .css("top", 0)
      .width(width)
      .height(height);
    this.game.puzzle.invalidate();
  }
}
