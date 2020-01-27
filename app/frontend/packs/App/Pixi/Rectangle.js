const Pixi = require("pixi.js");

exports.create = x => y => width => height =>
  Object.assign(
    new Pixi.Rectangle(x, y, width, height),
    { empty: false }
  );

exports.empty =
  Object.assign(
    new Pixi.Rectangle(0.0, 0.0, 0.0, 0.0),
    { empty: true }
  );

