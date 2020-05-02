const Pixi = require("pixi.js");

exports.create = x => y =>
  new Pixi.Point(x, y);
