import Puzzle from "./model/puzzle";

export default class Action {
  static fit(puzzle: Puzzle): void {
    const { innerWidth: width, innerHeight: height } = window;
    const rect = puzzle.boundary.inflate(puzzle.linearMeasure);
    const sc = Math.min(width / rect.width, height / rect.height);
    puzzle.container.x = -rect.x * sc + (width - sc * rect.width) / 2;
    puzzle.container.y = -rect.y * sc + (height - sc * rect.height) / 2;
    puzzle.container.scaleX = sc;
    puzzle.container.scaleY = sc;
    puzzle.stage.update();
  }
}
