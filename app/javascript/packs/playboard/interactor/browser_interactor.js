export default class BrowserInteractor {
  constructor(puzzle) {
    this.puzzle = puzzle;
  }

  attach() {
    $(window).on("resize", this.onWindowResize.bind(this));
    this.onWindowResize();
  }

  onWindowResize() {
    const { innerWidth: w, innerHeight: h } = window;
    // if $.browser.android?
    //   window.scrollTo(0, 1);

    this.puzzle.stage.canvas.width = w;
    this.puzzle.stage.canvas.height = h;
    $(this.puzzle.stage.canvas)
      .css("left", (window.innerWidth - w) / 2)
      .css("top", (window.innerHeight - h) / 2)
      .width(w)
      .height(h);
    this.puzzle.invalidate();
  }
}
