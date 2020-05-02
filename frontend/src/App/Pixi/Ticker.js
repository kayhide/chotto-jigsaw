const Pixi = require("pixi.js");


exports.getFPS = () => Pixi.Ticker.shared.FPS;

let xs = null;

exports.getMeasuredFPS = () => {
  if (!xs) {
    xs = new Array(60).fill(Pixi.Ticker.shared.deltaMS);
    Pixi.Ticker.shared.add(x => {
      xs.shift();
      xs.push(Pixi.Ticker.shared.elapsedMS);
    });
  }
  return 1000 * xs.length / xs.reduce((acc, x) => acc + x);
}

exports.onTick = action => () =>
  Pixi.Ticker.shared.add(x => action(x)());
