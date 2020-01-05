const EaselJS = require("@createjs/easeljs");

exports.create = () => new EaselJS.Shape();

exports.toDisplayObject = e => e;
