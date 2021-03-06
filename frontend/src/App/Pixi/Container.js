const Pixi = require("pixi.js");

exports.create = () => new Pixi.Container();

exports.addChild = _ => e => c => () => c.addChild(e);
exports.addShape = e => c => () => c.addChild(e);
exports.addContainer = e => c => () => c.addChild(e);

exports.getShapes = e => () => e.children;
