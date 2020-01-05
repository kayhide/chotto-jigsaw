const EaselJS = require("@createjs/easeljs");

exports.create = x => y =>
  new EaselJS.Point(x, y);
