const EaselJS = require("@createjs/easeljs");

exports.create = () => new EaselJS.Container();

exports.addChild = e => c => () => c.addChild(e);
exports.addShape = e => c => () => c.addChild(e);
exports.addContainer = e => c => () => c.addChild(e);

exports.getShapes = e => () => e.children;

exports.toDisplayObject = e => e;
