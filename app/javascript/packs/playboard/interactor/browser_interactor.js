export default class BrowserInteractor {
  constructor(game) {
    this.game = game;
  }

  attach() {
    $(window).on("resize", this.onWindowResize.bind(this));
    this.onWindowResize();
  }

  onWindowResize() {
    const { innerWidth: width, innerHeight: height } = window;

    Object.assign(this.game.canvas, { width, height });
    $(this.game.canvas)
      .css("left", (window.innerWidth - width) / 2)
      .css("top", (window.innerHeight - height) / 2)
      .width(width)
      .height(height);
    this.game.puzzle.invalidate();
  }
}
