const EaselJS = require("@createjs/easeljs");

exports.create = x => y => width => height =>
  Object.assign(
    new EaselJS.Rectangle(x, y, width, height),
    { empty: false }
  );

exports.empty =
  Object.assign(
    new EaselJS.Rectangle(0.0, 0.0, 0.0, 0.0),
    { empty: true }
  );

